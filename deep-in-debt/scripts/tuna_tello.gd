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
var garbage_mass: int
var bags_in_range: Array[Node2D] = []
var carried_bag: Node2D = null
var facing_direction := 1.0

func _ready() -> void:
	setup_FMOD_event_instances()

func setup_FMOD_event_instances():
	pass

func _physics_process(_delta: float) -> void:
	garbage_mass = get_collected_count()
	if garbage_mass < Globals.bag_slow_interval:
		SPEED = 250
	elif garbage_mass < (Globals.bag_slow_interval * 2):
		SPEED = 200
	elif garbage_mass < 30:
		SPEED = 150
	else:
		SPEED = 100
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED
	update_animation(velocity)
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact_bag"):
		handle_bag_interaction()


# ------------------------------------------------------------------
# Bag pickup / drop
# ------------------------------------------------------------------

func handle_bag_interaction() -> void:
	if is_instance_valid(carried_bag):
		if carried_bag.has_method("drop"):
			carried_bag.call("drop")
		carried_bag = null
		return

	carried_bag = null

	var bag := get_nearest_bag()

	if bag != null and bag.has_method("pick_up"):
		bag.call("pick_up", self)
		carried_bag = bag

		# Collect any garbage already standing inside the collection area.
		collect_all_in_range()


## The position garbage should fly to (same spot the bag sits at).
func get_carry_target_position() -> Vector2:
	if is_instance_valid(carried_bag) and carried_bag.has_method("get_carry_target_position"):
		var target: Vector2 = carried_bag.call("get_carry_target_position")
		return target

	return global_position

# ------------------------------------------------------------------
# Garbage collection
# ------------------------------------------------------------------

func _on_collection_area_area_entered(area: Area2D) -> void:
	# Only collect while holding a bag.
	if not is_instance_valid(carried_bag):
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

	if garbage.has_method("get_material_name"):
		material_name = str(garbage.call("get_material_name"))

	if garbage.has_method("collect"):
		garbage.call("collect", self)

	if material_name != "":
		# Store the material inside the bag the player is holding.
		if is_instance_valid(carried_bag) and carried_bag.has_method("add_collected_material"):
			carried_bag.call("add_collected_material", material_name)

		garbage_collected.emit(material_name)


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

	if is_instance_valid(carried_bag) and carried_bag.has_method("get_collected_materials"):
		result = carried_bag.call("get_collected_materials")

	return result


func get_last_collected_material() -> String:
	if is_instance_valid(carried_bag) and carried_bag.has_method("get_last_collected_material"):
		return str(carried_bag.call("get_last_collected_material"))

	return ""


func get_collected_count() -> int:
	if is_instance_valid(carried_bag) and carried_bag.has_method("get_collected_count"):
		return int(carried_bag.call("get_collected_count"))

	return 0


func state_collected_materials() -> String:
	if not is_instance_valid(carried_bag):
		return "You are not holding a bag."

	if carried_bag.has_method("state_collected_materials"):
		return str(carried_bag.call("state_collected_materials"))

	return ""

# ------------------------------------------------------------------
# Interaction area (bag pickup)
# ------------------------------------------------------------------

func _on_interaction_area_area_entered(area: Area2D) -> void:
	var bag := get_bag_from_area(area)

	if bag != null and not bags_in_range.has(bag):
		bags_in_range.append(bag)


func _on_interaction_area_area_exited(area: Area2D) -> void:
	var bag := get_bag_from_area(area)

	if bag != null:
		bags_in_range.erase(bag)


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
