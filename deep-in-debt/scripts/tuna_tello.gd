extends CharacterBody2D

var SPEED = 250.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = get_node_or_null("InteractionArea") as Area2D
@onready var collection_area: Area2D = get_node_or_null("CollectionArea") as Area2D

# the event paths given by fmod
@export_group("sfx references")
@export var footsteps : String


# the event instances (they start empty and are initialized in the setup_FMOD_event_instances function, called on _ready)

## Emitted every time a garbage item is collected.
signal garbage_collected(material_name: String)

# fixed it so there's only one garbage mass variable
var bags_in_range: Array[Node2D] = []
var facing_direction := 1.0

var whales_in_range: Array[Node2D] = []
var sharks_in_range: Array[Node2D] = []
var koi_in_range: Array[Node2D] = []
var carp_in_range: Array[Node2D] = []
var octopi_in_range: Array[Node2D] = []
var cake_in_range: Array[Node2D] = []
var goldfishes_in_range: Array[Node2D] = []

func _ready() -> void:
	setup_FMOD_event_instances()

func setup_FMOD_event_instances():
	pass

func _physics_process(_delta: float) -> void:
	Globals.player_garbage_carry_count = get_collected_count()
	if Globals.player_garbage_carry_count < (Globals.bag_slow_interval * 2):
		SPEED = 250
	elif Globals.player_garbage_carry_count < (Globals.bag_slow_interval * 3):
		SPEED = 200
	else:
		SPEED = 100
	
	if not Globals.in_cutscene:
		velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED
	else:
		velocity = Vector2.ZERO
	update_animation(velocity)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var whale := get_nearest_whale()

		if whale != null:
			if whale.has_method("interact"):
				whale.call("interact")
			return  # delete this line if the bag logic should ALSO run

		var shark := get_nearest_shark()

		if shark != null:
			if not Globals.in_cutscene:
				if shark.has_method("talk"):
					shark.call("talk")
				return  # delete this line if the bag logic should ALSO run

		var koi := get_nearest_koi()

		if koi != null:
			if not Globals.in_cutscene:
				if koi.has_method("buy"):
					koi.call("buy")
				return  # delete this line if the bag logic should ALSO run

		handle_bag_interaction()

# ------------------------------------------------------------------
# Interaction area (bag pickup)
# ------------------------------------------------------------------

func _on_interaction_area_area_entered(area: Area2D) -> void:
	var bag := get_bag_from_area(area)

	if bag != null and not bags_in_range.has(bag):
		bags_in_range.append(bag)
	
	var whale := get_whale_from_area(area)

	if whale != null and not whales_in_range.has(whale):
		whales_in_range.append(whale)
	
	var shark := get_shark_from_area(area)

	if shark != null and not sharks_in_range.has(shark):
		sharks_in_range.append(shark)
	
	var koi := get_koi_from_area(area)

	if koi != null and not koi_in_range.has(koi):
		koi_in_range.append(koi)


func _on_interaction_area_area_exited(area: Area2D) -> void:
	var bag := get_bag_from_area(area)

	if bag != null:
		bags_in_range.erase(bag)

	var whale := get_whale_from_area(area)
	
	if whale != null:
		whales_in_range.erase(whale)
	
	var shark := get_shark_from_area(area)
	
	if shark != null:
		sharks_in_range.erase(shark)

	var koi := get_koi_from_area(area)

	if koi != null:
		sharks_in_range.erase(koi)

# ------------------------------------------------------------------
# Bag pickup / drop
# ------------------------------------------------------------------

func handle_bag_interaction() -> void:
	if is_instance_valid(Globals.carried_bag):
		if Globals.carried_bag.has_method("drop"):
			Globals.carried_bag.call("drop")
		Globals.carried_bag = null
		Globals.is_player_carrying_a_bag = false
		return

	Globals.carried_bag = null

	var bag := get_nearest_bag()

	if bag != null and bag.has_method("pick_up"):
		bag.call("pick_up", self)
		Globals.carried_bag = bag
		Globals.is_player_carrying_a_bag = true
		# Collect any garbage already standing inside the collection area.
		collect_all_in_range()


## The position garbage should fly to (same spot the bag sits at).
func get_carry_target_position() -> Vector2:
	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_carry_target_position"):
		var target: Vector2 = Globals.carried_bag.call("get_carry_target_position")
		return target

	return global_position

# ------------------------------------------------------------------
# Garbage collection
# ------------------------------------------------------------------

func _on_collection_area_area_entered(area: Area2D) -> void:
	# Only collect while holding a bag.
	if not is_instance_valid(Globals.carried_bag):
		return

	var garbage := get_garbage_from_area(area)

	if garbage == null:
		return

	if garbage.has_method("is_collectable") and not garbage.call("is_collectable"):
		return

	collect_garbage(garbage)


func collect_all_in_range() -> void:
	if collection_area == null:
		return

	for area in collection_area.get_overlapping_areas():
		_on_collection_area_area_entered(area)


func collect_garbage(garbage: Node2D) -> void:
	var material_name := ""
	if get_collected_count() < (Globals.bag_slow_interval * 3):
		if garbage.has_method("get_material_name"):
			material_name = str(garbage.call("get_material_name"))

		if garbage.has_method("collect"):
			garbage.call("collect", self)

		if material_name != "":
			# Store the material inside the bag the player is holding.
			if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("add_collected_material"):
				Globals.carried_bag.call("add_collected_material", material_name)
			garbage_collected.emit(material_name)

	else:
		pass


func get_garbage_from_area(area: Area2D) -> Node2D:
	if area.is_in_group("garbage"):
		return area

	var parent := area.get_parent() as Node2D

	if parent != null and parent.is_in_group("garbage"):
		return parent

	return null


# ------------------------------------------------------------------
# Functions that state what material was collected
# ------------------------------------------------------------------

func get_collected_materials() -> Array[String]:
	var result: Array[String] = []

	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_collected_materials"):
		result = Globals.carried_bag.call("get_collected_materials")

	return result

func get_last_collected_material() -> String:
	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_last_collected_material"):
		return str(Globals.carried_bag.call("get_last_collected_material"))

	return ""

func get_collected_count() -> int:
	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_collected_count"):
		return int(Globals.carried_bag.call("get_collected_count"))

	return 0

func state_collected_materials() -> String:
	if not is_instance_valid(Globals.carried_bag):
		return "You are not holding a bag."

	if Globals.carried_bag.has_method("state_collected_materials"):
		return str(Globals.carried_bag.call("state_collected_materials"))

	return ""

# BAG HELPER FUNCTIONS

func get_bag_from_area(area: Area2D) -> Node2D:
	if area.is_in_group("bag"):
		return area

	var parent := area.get_parent() as Node2D

	if parent != null and parent.is_in_group("bag"):
		return parent

	return null


func get_nearest_bag() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for bag in bags_in_range:
		if not is_instance_valid(bag):
			continue

		if bag.has_method("is_carried") and bag.call("is_carried"):
			continue

		if bag.has_method("can_be_picked_up") and not bag.call("can_be_picked_up"):
			continue

		var distance := global_position.distance_squared_to(bag.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = bag

	return nearest

## The group is on the Area2D, so return its parent (the whale root).
func get_whale_from_area(area: Area2D) -> Node2D:
	if area.is_in_group("mon_whale"):
		return area.get_parent() as Node2D

	var parent := area.get_parent() as Node2D
	if parent != null and parent.is_in_group("mon_whale"):
		return parent
	
	return null

func get_nearest_whale() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for whale in whales_in_range:
		if not is_instance_valid(whale):
			continue

		var distance := global_position.distance_squared_to(whale.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = whale

	return nearest

## The group is on the Area2D, so return its parent (the shark root).
func get_shark_from_area(area: Area2D) -> Node2D:
	if area.is_in_group("picass_shark"):
		return area.get_parent() as Node2D

	var parent := area.get_parent() as Node2D
	if parent != null and parent.is_in_group("picass_shark"):
		return parent

	return null

func get_nearest_shark() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for shark in sharks_in_range:
		if not is_instance_valid(shark):
			continue

		var distance := global_position.distance_squared_to(shark.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = shark

	return nearest

## The group is on the Area2D, so return its parent (the shark root).
func get_koi_from_area(area: Area2D) -> Node2D:
	if area.is_in_group("mikoi_angelo"):
		return area.get_parent() as Node2D

	var parent := area.get_parent() as Node2D
	if parent != null and parent.is_in_group("mikoi_angelo"):
		return parent

	return null

func get_nearest_koi() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for koi in koi_in_range:
		if not is_instance_valid(koi):
			continue

		var distance := global_position.distance_squared_to(koi.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = koi

	return nearest

func update_animation(movement: Vector2) -> void:
	if movement == Vector2.ZERO:
		if animated_sprite_2d.animation != "Idle":
			animated_sprite_2d.play("Idle")
	else:
		if animated_sprite_2d.animation != "Walk":
			animated_sprite_2d.play("Walk")

	if movement.x > 0.0:
		animated_sprite_2d.flip_h = false
		facing_direction = 1.0

	elif movement.x < 0.0:
		animated_sprite_2d.flip_h = true
		facing_direction = -1.0


func get_facing_direction() -> float:
	return facing_direction


func _on_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "Walk" and $AnimatedSprite2D.frame == 0 or $AnimatedSprite2D.frame == 3:
		Globals.play_fmod_sfx(footsteps)
