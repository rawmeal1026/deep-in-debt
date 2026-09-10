extends CharacterBody2D

## Emitted every time this worker collects garbage.
signal garbage_collected(material_name: String)

var SPEED: float = 200.0
@export var bag_group: String = "bag"
@export var garbage_group: String = "garbage"
@export var whale_group: String = "mon_whale"
@export var move_stop_distance: float = 2.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var carried_bag: Node2D = null
var is_carrying_bag: bool = false
var facing_direction: float = 1.0
var no_bags: bool = true

@onready var collection_area: Area2D = get_node_or_null("CollectionArea") as Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

var bags_in_range: Array[Node2D] = []
var whales_in_range:  Array[Node2D] = []

func _physics_process(_delta: float) -> void:
	var target: Vector2 = Vector2.ZERO
	var has_target := false

	# Nearest collectable waste this frame (null = the world is clean).
	var garbage := get_nearest_garbage_target()

	# 1. Determine the target based on current state
	if is_carrying_bag and is_instance_valid(carried_bag):
		if is_bag_full(carried_bag):
			drop_current_bag()
		elif garbage != null:
			target = garbage.global_position
			has_target = true
		else:
			# No waste left to collect: drop the partial bag
			# so the hauler can take it away.
			drop_current_bag()
	else:
		if is_carrying_bag and not is_instance_valid(carried_bag):
			clear_carried_bag()

		# Only hunt for bags / whale while waste actually exists.
		# Otherwise we'd instantly re-pick-up the bag we just dropped.
		if garbage != null:
			var bag := get_nearest_available_bag_target()

			if bag != null:
				if no_bags == true:
					no_bags = false
				target = bag.global_position
				has_target = true
			else:
				if no_bags == false:
					no_bags = true
				var whale := get_nearest_whale_target()

				if whale != null:
					target = whale.global_position
					has_target = true

	# 2. Handle Movement via NavigationAgent
	if has_target:
		# Check if we are close enough to the final destination to stop
		if global_position.distance_to(target) <= move_stop_distance:
			velocity = Vector2.ZERO
			nav_agent.target_position = global_position # Stop navigating

			# Arrival retry: pick up a bag we are already standing inside
			# (its area_entered fired long ago, so it won't fire again).
			if not is_carrying_bag:
				handle_bag_interaction()
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
	move_and_slide()


# ------------------------------------------------------------------
# Movement helper
# ------------------------------------------------------------------

func move_towards(target_position: Vector2) -> void:
	if global_position.distance_to(target_position) > move_stop_distance:
		velocity = (target_position - global_position).normalized() * SPEED
	else:
		velocity = Vector2.ZERO


# ------------------------------------------------------------------
# InteractionArea handling
# ------------------------------------------------------------------

func _on_interaction_area_area_entered(area: Area2D) -> void:
	var bag := get_bag_from_area(area)

	if bag != null and not bags_in_range.has(bag):
		bags_in_range.append(bag)

	if is_carrying_bag:
		return

	handle_bag_interaction()

	if is_carrying_bag:
		return
	var whale := get_whale_from_area(area)

	if whale != null and not whales_in_range.has(whale):
		whales_in_range.append(whale)

	var whale_to_interact := get_nearest_whale()

	if whale_to_interact != null:
		if no_bags == true:
			if whale_to_interact.has_method("worker_interact"):
				whale_to_interact.call("worker_interact")
		return  # delete this line if the bag logic should ALSO run


func _on_interaction_area_area_exited(area: Area2D) -> void:
	var bag := get_bag_from_area(area)

	if bag != null:
		bags_in_range.erase(bag)

	var whale := get_whale_from_area(area)

	if whale != null:
		whales_in_range.erase(whale)


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

		if bag.has_method("is_full") and bag.call("is_full"):
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

# ------------------------------------------------------------------
# CollectionArea handling
# ------------------------------------------------------------------

func _on_collection_area_area_entered(area: Area2D) -> void:
	if not is_carrying_bag:
		return

	if not is_instance_valid(carried_bag):
		clear_carried_bag()
		return

	if is_bag_full(carried_bag):
		drop_current_bag()
		return

	if is_area_part_of_bag(area):
		return

	var garbage := get_garbage_from_area(area)

	if garbage == null or garbage == carried_bag:
		return

	if garbage.has_method("is_collectable") and not garbage.call("is_collectable"):
		return

	collect_garbage(garbage)


func collect_all_in_range() -> void:
	if collection_area == null:
		return

	for area in collection_area.get_overlapping_areas():
		_on_collection_area_area_entered(area)


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
			collect_all_in_range()


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
# Garbage collection
# ------------------------------------------------------------------

func collect_garbage(garbage: Node2D) -> void:
	if get_collected_count() >= Globals.bag_slow_interval * 3:
		return

	var material_name := ""

	if garbage.has_method("get_material_name"):
		material_name = str(garbage.call("get_material_name"))

	if garbage.has_method("collect"):
		garbage.call("collect", self)

	if material_name != "" and is_instance_valid(carried_bag) and carried_bag.has_method("add_collected_material"):
		carried_bag.call("add_collected_material", material_name)
		garbage_collected.emit(material_name)


func get_garbage_from_area(area: Area2D) -> Node2D:
	var garbage: Node2D = null

	if area.is_in_group(garbage_group):
		garbage = area
	else:
		var area_parent := area.get_parent() as Node2D

		if area_parent != null and area_parent.is_in_group(garbage_group):
			garbage = area_parent

	if garbage == null or garbage.is_in_group(bag_group):
		return null

	if garbage.has_method("collect"):
		return garbage

	var garbage_parent := garbage.get_parent() as Node2D

	if garbage_parent != null and garbage_parent.has_method("collect") and not garbage_parent.is_in_group(bag_group):
		return garbage_parent

	return garbage


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

		if bag.has_method("is_full") and bag.call("is_full"):
			continue

		var distance := global_position.distance_squared_to(target.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = target

	return nearest


func get_nearest_garbage_target() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for node in get_tree().get_nodes_in_group(garbage_group):
		var target := node as Node2D

		if target == null or not is_instance_valid(target):
			continue

		var garbage := get_garbage_root(target)

		if garbage == null or not is_instance_valid(garbage):
			continue

		if garbage == carried_bag or garbage.is_in_group(bag_group):
			continue

		if not garbage.has_method("collect"):
			continue

		if garbage.has_method("is_collectable") and not garbage.call("is_collectable"):
			continue

		if garbage.has_method("is_collected") and garbage.call("is_collected"):
			continue

		var distance := global_position.distance_squared_to(target.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = target

	return nearest


func get_nearest_whale_target() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for node in get_tree().get_nodes_in_group(whale_group):
		var target := node as Node2D

		if target == null or not is_instance_valid(target):
			continue

		var whale := get_whale_root(target)

		if whale == null or not is_instance_valid(whale):
			continue

		if not whale.has_method("worker_interact"):
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


func get_garbage_root(node: Node2D) -> Node2D:
	if node == null:
		return null

	if node.has_method("collect"):
		return node

	var parent := node.get_parent() as Node2D

	if parent != null and parent.has_method("collect"):
		return parent

	return node


func get_whale_root(node: Node2D) -> Node2D:
	if node == null:
		return null

	if node.has_method("worker_interact"):
		return node

	var parent := node.get_parent() as Node2D

	if parent != null and parent.has_method("worker_interact"):
		return parent

	return node


func is_area_part_of_bag(area: Area2D) -> bool:
	if area.is_in_group(bag_group):
		return true

	var parent := area.get_parent() as Node2D

	return parent != null and parent.is_in_group(bag_group)


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
