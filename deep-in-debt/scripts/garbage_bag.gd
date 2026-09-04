extends Node2D

# Emitted when the bag starts moving.
signal started_moving(direction)

# Emitted every physics frame while the bag is moving.
signal moving(direction)

# Emitted when the bag stops moving.
signal stopped_moving


# Where the bag sits while being carried.
@export var carry_offset := Vector2(-24.0, 8.0)

# Pickup animation time.
@export var pickup_time := 0.25

# How slow the bag starts moving toward the player.
@export var pickup_start_sharpness := 3.0

# How strongly the bag follows the player after pickup.
# If this is too high, it can jitter.
# Good range: 6 to 14.
@export var follow_sharpness := 10.0

# How quickly the carry offset adjusts when the player turns around.
# This prevents the bag from snapping instantly from left to right.
@export var offset_follow_sharpness := 12.0

# Where the bag lands when dropped.
@export var drop_offset := Vector2(0.0, 16.0)

# Drop animation time.
@export var drop_time := 0.15

# Prevents instant re-pickup.
@export var drop_pickup_delay := 0.3

# If true, drop_offset.x flips based on player facing.
@export var flip_drop_offset_x_with_facing := false

# Minimum speed before the bag counts as moving.
@export var move_threshold := 1.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# the event paths given by fmod
@export_group("sfx references")
@export var pickup_bag : String
@export var putdown_bag : String
@export var pickup_bottle : String
@export var putdown_bottle : String
@export var pickup_can : String
@export var putdown_can : String
@export var pickup_milk : String
@export var putdown_milk : String

var player: CharacterBody2D = null
var carried := false
var can_pick_up := true

# Pickup animation blend.
var pickup_blend := 0.0
var pickup_tween: Tween = null

# Drop animation progress.
var drop_progress := 1.0
var drop_start_position := Vector2.ZERO
var drop_target_position := Vector2.ZERO
var drop_tween: Tween = null

# Smoothed carry offset.
var current_carry_offset := Vector2.ZERO

# Movement detection.
var current_velocity := Vector2.ZERO
var move_direction := Vector2.ZERO
var is_moving := false
var previous_global_position := Vector2.ZERO

## Every material collected into this bag.
var collected_materials: Array[String] = []
var garbage_mass

# INITIALIZE
func _ready() -> void:
	setup_FMOD_event_instances()
	add_to_group("bag")

	previous_global_position = global_position
	current_carry_offset = carry_offset

	set_physics_process(true)

	# Try to make the bag update after the player.
	# If your Godot version does not expose this property, set it manually:
	# GarbageBag > Node > Process > Physics Process Priority = 100
	if "physics_process_priority" in self:
		set("physics_process_priority", 100)
	elif "process_physics_priority" in self:
		set("process_physics_priority", 100)
	
	started_moving.connect(_on_started_moving_debug)
	moving.connect(_on_moving_debug)
	stopped_moving.connect(_on_stopped_moving_debug)

func _physics_process(delta: float) -> void:
	garbage_mass = get_collected_count()
	if carried and player != null:
		update_carry_follow(delta)

	elif drop_progress < 1.0:
		global_position = drop_start_position.lerp(drop_target_position, drop_progress)

	update_movement_detection(delta)

func setup_FMOD_event_instances():
	pass
	
# BAG CONTENTS FUNCTIONS
func add_collected_material(material_name: String) -> void:
	match material_name:
		"PET Bottles":
			Globals.play_fmod_sfx(pickup_bottle)
		"Aluminum Cans":
			Globals.play_fmod_sfx(pickup_can)
		"Cellulose Paperboards":
			Globals.play_fmod_sfx(pickup_milk)
		"PE Bags":
			Globals.play_fmod_sfx(pickup_bag)
	collected_materials.append(material_name)
	

func get_collected_materials() -> Array[String]:
	return collected_materials

func get_collected_count() -> int:
	return collected_materials.size()

func get_last_collected_material() -> String:
	if collected_materials.is_empty():
		return ""

	return collected_materials[-1]

func has_material(material_name: String) -> bool:
	return collected_materials.has(material_name)

func clear_collected_materials() -> void:
	collected_materials.clear()

func state_collected_materials() -> String:
	if collected_materials.is_empty():
		return "The bag is empty."

	var text := "Bag contains: "

	for i in range(collected_materials.size()):
		text += collected_materials[i]

		if i < collected_materials.size() - 1:
			text += ", "
	
	return text

# BAG STATE FUNCTIONS
func can_be_picked_up() -> bool:
	return can_pick_up and not carried

func is_carried() -> bool:
	return carried


# PLAYER GARBAGE BAG INTERACTION

func pick_up(new_player: CharacterBody2D) -> void:
	if not can_be_picked_up():
		return

	Globals.play_fmod_sfx(pickup_bag, "garbage_mass", garbage_mass)
	
	carried = true
	can_pick_up = false
	player = new_player

	pickup_blend = 0.0
	drop_progress = 1.0

	if player != null:
		current_carry_offset = global_position - player.global_position

	kill_tweens()

	if pickup_time <= 0.0:
		pickup_blend = 1.0
	else:
		pickup_tween = create_tween()

		# Very important: sync the tween with physics.
		pickup_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

		# Smoother pickup curve.
		pickup_tween.set_trans(Tween.TRANS_SINE)
		pickup_tween.set_ease(Tween.EASE_OUT)

		pickup_tween.tween_property(self, "pickup_blend", 1.0, pickup_time)
	#PICKUP SOUND HERE
	

func drop() -> void:
	if not carried:
		return

	carried = false
	can_pick_up = false

	var old_player := player
	player = null

	kill_tweens()

	var target_position := global_position

	if is_instance_valid(old_player):
		var direction := 1.0

		if flip_drop_offset_x_with_facing and old_player.has_method("get_facing_direction"):
			direction = float(old_player.call("get_facing_direction"))

		target_position = old_player.global_position + Vector2(
			drop_offset.x * direction,
			drop_offset.y
		)

	drop_start_position = global_position
	drop_target_position = target_position
	drop_progress = 0.0

	if drop_time <= 0.0:
		drop_progress = 1.0
		global_position = target_position

		# Avoid counting the instant teleport as movement.
		previous_global_position = global_position
	else:
		drop_tween = create_tween()

		# Very important: sync the tween with physics.
		drop_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

		drop_tween.set_trans(Tween.TRANS_SINE)
		drop_tween.set_ease(Tween.EASE_OUT)

		# Do NOT tween global_position directly.
		# Tween progress instead, then apply position in _physics_process.
		drop_tween.tween_property(self, "drop_progress", 1.0, drop_time)

	if drop_pickup_delay <= 0.0:
		_finish_drop_pickup_delay()
	else:
		get_tree().create_timer(drop_pickup_delay).timeout.connect(_finish_drop_pickup_delay)
	Globals.play_fmod_sfx(putdown_bag, "garbage_mass", garbage_mass)

func _finish_drop_pickup_delay() -> void:
	if not carried:
		can_pick_up = true

func kill_tweens() -> void:
	if pickup_tween != null and pickup_tween.is_valid():
		pickup_tween.kill()

	pickup_tween = null

	if drop_tween != null and drop_tween.is_valid():
		drop_tween.kill()

	drop_tween = null


# PLAYER READING FUNCTIONS
func get_player_facing_direction() -> float:
	if player != null and player.has_method("get_facing_direction"):
		return float(player.call("get_facing_direction"))

	return 1.0

func get_target_carry_offset() -> Vector2:
	var direction := get_player_facing_direction()

	return Vector2(
		carry_offset.x * direction,
		carry_offset.y
	)

func get_carry_target_position() -> Vector2:
	if player == null:
		return global_position

	return player.global_position + current_carry_offset

# MOVEMENT FUNCTIONS
func update_carry_follow(delta: float) -> void:
	# Smoothly adjust the carry offset.
	# This stops the bag from snapping when the player turns around.
	var target_offset := get_target_carry_offset()
	var offset_weight := 1.0 - exp(-offset_follow_sharpness * delta)

	current_carry_offset = current_carry_offset.lerp(target_offset, offset_weight)

	var target := player.global_position + current_carry_offset

	# Start the pickup slowly, then become normal follow strength.
	var sharpness = lerp(pickup_start_sharpness, follow_sharpness, pickup_blend)
	var weight := 1.0 - exp(-sharpness * delta)

	global_position = global_position.lerp(target, weight)

	# Snap when close enough to avoid tiny endless micro-adjustments.
	if pickup_blend >= 1.0 and global_position.distance_to(target) < 0.2:
		global_position = target

func update_movement_detection(delta: float) -> void:
	if delta <= 0.0:
		return

	current_velocity = (global_position - previous_global_position) / delta
	previous_global_position = global_position

	var was_moving := is_moving

	is_moving = current_velocity.length() > move_threshold

	if is_moving:
		move_direction = current_velocity.normalized()
		moving.emit(move_direction)
	else:
		move_direction = Vector2.ZERO

	if is_moving and not was_moving:
		started_moving.emit(move_direction)

	elif not is_moving and was_moving:
		stopped_moving.emit()


func get_move_direction_name() -> String:
	if not is_moving:
		return "none"

	if abs(move_direction.x) > abs(move_direction.y):
		if move_direction.x > 0.0:
			return "right"
		else:
			return "left"
	else:
		if move_direction.y > 0.0:
			return "down"
		else:
			return "up"

func _on_started_moving_debug(_direction: Vector2) -> void:
	if garbage_mass < 1:
		animated_sprite_2d.play("Drag1")
	elif garbage_mass < (Globals.bag_slow_interval * 2):
		animated_sprite_2d.play("Drag2")
	elif garbage_mass < (Globals.bag_slow_interval * 3):
		animated_sprite_2d.play("Drag3")
	else:
		animated_sprite_2d.play("Drag4")

func _on_moving_debug(direction: Vector2) -> void:
	if garbage_mass < 1:
		if animated_sprite_2d.animation != "Drag1":
			animated_sprite_2d.play("Drag1")
	elif garbage_mass < (Globals.bag_slow_interval * 2):
		if animated_sprite_2d.animation != "Drag2":
			animated_sprite_2d.play("Drag2")
	elif garbage_mass < (Globals.bag_slow_interval * 3):
		if animated_sprite_2d.animation != "Drag3":
			animated_sprite_2d.play("Drag3")
	else:
		if animated_sprite_2d.animation != "Drag4":
			animated_sprite_2d.play("Drag4")
	if direction.x > 0:
		animated_sprite_2d.flip_h = false
	if direction.x < 0:
		animated_sprite_2d.flip_h = true

func _on_stopped_moving_debug() -> void:
	if garbage_mass < 1:
		animated_sprite_2d.play("Idle1")
	elif garbage_mass < (Globals.bag_slow_interval * 2):
		animated_sprite_2d.play("Idle2")
	elif garbage_mass < (Globals.bag_slow_interval * 3):
		animated_sprite_2d.play("Idle3")
	else:
		animated_sprite_2d.play("Idle4")
