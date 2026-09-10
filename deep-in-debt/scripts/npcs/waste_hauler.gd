extends CharacterBody2D

@export var locked_walk_frames: Array[int] = [1, 2, 3, 8, 9, 10]
@export var SPEED: float = 200
@export var bag_group: String = "bag"
@export var koi_group: String = "mikoi_angelo"
@export var move_stop_distance: float = 2.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var carried_bag: Node2D = null
var is_carrying_bag: bool = false
var facing_direction: float = 1.0

@onready var animated_sprite_2d: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

var bags_in_range: Array[Node2D] = []
var kois_in_range:  Array[Node2D] = []

func _physics_process(_delta: float) -> void:
	var target: Vector2 = Vector2.ZERO
	var has_target := false

	# 1. Determine the target based on current state
	if is_carrying_bag and is_instance_valid(carried_bag):
		# Carrying a full bag: deliver it to the nearest koi.
		var koi := get_nearest_koi_target()

		if koi != null:
			target = koi.global_position
			has_target = true
	else:
		if is_carrying_bag and not is_instance_valid(carried_bag):
			clear_carried_bag()

		# Not carrying: hunt for a FULL bag to haul.
		var bag := get_nearest_available_bag_target()

		if bag != null:
			target = bag.global_position
			has_target = true

	# 2. Handle Movement via NavigationAgent
	if has_target:
		# Check if we are close enough to the final destination to stop
		if global_position.distance_to(target) <= move_stop_distance:
			velocity = Vector2.ZERO
			nav_agent.target_position = global_position # Stop navigating
		else:
			nav_agent.target_position = target
			
			if nav_agent.is_navigation_finished():
				velocity = Vector2.ZERO
			else:
				# Get the next safe waypoint on the path around the wall
				var next_path_position: Vector2 = nav_agent.get_next_path_position()
				var direction: Vector2 = (next_path_position - global_position).normalized()
				velocity = direction * SPEED
	else:
		# No target, stop moving and clear navigation
		velocity = Vector2.ZERO
		nav_agent.target_position = global_position

	update_animation(velocity)
	apply_walk_frame_lock()
	move_and_slide()


# ------------------------------------------------------------------
# Movement helper
# ------------------------------------------------------------------

func move_towards(target_position: Vector2) -> void:
	if global_position.distance_to(target_position) > move_stop_distance:
		velocity = (target_position - global_position).normalized() * SPEED
	else:
		velocity = Vector2.ZERO

## Freezes movement while the Walk animation is showing one of the locked
## frames, giving the hauler his stuttering gait.
## Must run AFTER update_animation() and BEFORE move_and_slide().
func apply_walk_frame_lock() -> void:
	if animated_sprite_2d == null:
		return

	if animated_sprite_2d.animation != "Walk":
		return

	# AnimatedSprite2D.frame is 0-based; locked_walk_frames uses 1-based
	# human numbering (frame 1 = index 0).
	var current_frame := animated_sprite_2d.frame + 1

	if locked_walk_frames.has(current_frame):
		velocity = Vector2.ZERO

# ------------------------------------------------------------------
# InteractionArea handling
# ------------------------------------------------------------------

func _on_interaction_area_area_entered(area: Area2D) -> void:
	var bag := get_bag_from_area(area)

	if bag != null and not bags_in_range.has(bag):
		bags_in_range.append(bag)

	var koi := get_koi_from_area(area)

	if koi != null and not kois_in_range.has(koi):
		kois_in_range.append(koi)

	if not is_carrying_bag:
		handle_bag_interaction()
		return

	var koi_to_interact := get_nearest_koi()

	if koi_to_interact != null:
		if koi_to_interact.has_method("worker_interact"):
			koi_to_interact.call("worker_interact", self)


func _on_interaction_area_area_exited(area: Area2D) -> void:
	var bag := get_bag_from_area(area)

	if bag != null:
		bags_in_range.erase(bag)

	var koi := get_koi_from_area(area)

	if koi != null:
		kois_in_range.erase(koi)


func get_nearest_bag() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for bag in bags_in_range.duplicate():
		if not is_instance_valid(bag):
			bags_in_range.erase(bag)
			continue

		if not bag.has_method("pick_up"):
			continue

		if bag.has_method("is_carried") and bag.call("is_carried"):
			continue

		if bag.has_method("can_be_picked_up") and not bag.call("can_be_picked_up"):
			continue

		if bag.has_method("get_collected_count") and int(bag.call("get_collected_count")) <= 0:
			continue

		var distance := global_position.distance_squared_to(bag.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = bag

	return nearest


func get_bag_from_area(area: Area2D) -> Node2D:
	if area.is_in_group(bag_group):
		return area

	var parent := area.get_parent() as Node2D

	if parent != null and parent.is_in_group(bag_group):
		return parent

	return null

## The group is on the Area2D, so return its parent (the koi root).
func get_koi_from_area(area: Area2D) -> Node2D:
	if area.is_in_group(koi_group):
		return area.get_parent() as Node2D

	var parent := area.get_parent() as Node2D
	if parent != null and parent.is_in_group(koi_group):
		return parent
	
	return null

func get_nearest_koi() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for koi in kois_in_range:
		if not is_instance_valid(koi):
			continue

		var distance := global_position.distance_squared_to(koi.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = koi

	return nearest

# ------------------------------------------------------------------
# Bag pickup / drop
# ------------------------------------------------------------------

func handle_bag_interaction() -> void:
	if is_instance_valid(carried_bag):
		if carried_bag.has_method("drop"):
			carried_bag.call("drop")

		clear_carried_bag()
		return

	var bag := get_nearest_bag()

	if bag != null and bag.has_method("pick_up"):
		bag.call("pick_up", self)

		if bag.has_method("is_carried") and bag.call("is_carried"):
			carried_bag = bag
			is_carrying_bag = true


func drop_current_bag() -> void:
	if is_instance_valid(carried_bag):
		if carried_bag.has_method("drop"):
			carried_bag.call("drop")

	clear_carried_bag()


func clear_carried_bag() -> void:
	carried_bag = null
	is_carrying_bag = false


func is_bag_full(bag: Node2D) -> bool:
	if not is_instance_valid(bag):
		return true

	if bag.has_method("is_full"):
		return bool(bag.call("is_full"))

	return false


# ------------------------------------------------------------------
# Required carrier helper functions
# ------------------------------------------------------------------

func get_carry_target_position() -> Vector2:
	if is_instance_valid(carried_bag) and carried_bag.has_method("get_carry_target_position"):
		return carried_bag.call("get_carry_target_position")

	return global_position


func get_collected_count() -> int:
	if is_instance_valid(carried_bag) and carried_bag.has_method("get_collected_count"):
		return int(carried_bag.call("get_collected_count"))

	return 0


func get_facing_direction() -> float:
	return facing_direction


# ------------------------------------------------------------------
# Nearest target finding
# ------------------------------------------------------------------

func get_nearest_available_bag_target() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for node in get_tree().get_nodes_in_group(bag_group):
		var target := node as Node2D

		if target == null or not is_instance_valid(target):
			continue

		var bag := get_bag_root(target)

		if bag == null or not is_instance_valid(bag):
			continue

		if bag == carried_bag:
			continue

		if not bag.has_method("pick_up"):
			continue

		if bag.has_method("is_carried") and bag.call("is_carried"):
			continue

		if bag.has_method("can_be_picked_up") and not bag.call("can_be_picked_up"):
			continue

		# The hauler ONLY targets FULL bags.
		if bag.has_method("get_collected_count") and int(bag.call("get_collected_count")) <= 0:
			continue

		var distance := global_position.distance_squared_to(target.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = target

	return nearest


func get_nearest_koi_target() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for node in get_tree().get_nodes_in_group(koi_group):
		var target := node as Node2D

		if target == null or not is_instance_valid(target):
			continue

		var koi := get_koi_root(target)

		if koi == null or not is_instance_valid(koi):
			continue

		if not koi.has_method("worker_interact"):
			continue

		var distance := global_position.distance_squared_to(target.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = target

	return nearest


# ------------------------------------------------------------------
# Area-to-root helpers
# ------------------------------------------------------------------


func get_bag_root(node: Node2D) -> Node2D:
	if node == null:
		return null

	if node.has_method("pick_up"):
		return node

	var parent := node.get_parent() as Node2D

	if parent != null and parent.has_method("pick_up"):
		return parent

	return node


func get_koi_root(node: Node2D) -> Node2D:
	if node == null:
		return null

	if node.has_method("worker_interact"):
		return node

	var parent := node.get_parent() as Node2D

	if parent != null and parent.has_method("worker_interact"):
		return parent

	return node


# ------------------------------------------------------------------
# Animation
# ------------------------------------------------------------------

func update_animation(movement: Vector2) -> void:
	if animated_sprite_2d == null:
		return

	if movement == Vector2.ZERO:
		if animated_sprite_2d.animation != "Idle":
			play_animation_if_exists("Idle")
	else:
		if animated_sprite_2d.animation != "Walk":
			play_animation_if_exists("Walk")

	if movement.x > 0.0:
		animated_sprite_2d.flip_h = false
		facing_direction = 1.0
	elif movement.x < 0.0:
		animated_sprite_2d.flip_h = true
		facing_direction = -1.0


func play_animation_if_exists(animation_name: String) -> void:
	if animated_sprite_2d == null:
		return

	if animated_sprite_2d.sprite_frames != null and animated_sprite_2d.sprite_frames.has_animation(animation_name):
		animated_sprite_2d.play(animation_name)
