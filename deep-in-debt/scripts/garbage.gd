extends Node2D

## Emitted after randomization with the chosen material name.
signal material_assigned(material_name: String)

## Emitted right before the garbage vanishes.
signal collected(material_name: String)


## How long the fly-to-bag animation takes.
@export var collect_time := 0.35

var current_material := ""
var current_sprite: Sprite2D = null

var being_collected := false
var collector: Node2D = null
var collect_blend := 0.0
var collect_tween: Tween = null


func _ready() -> void:
	add_to_group("garbage")

	# Update after the player so it follows smoothly.
	if "physics_process_priority" in self:
		set("physics_process_priority", 100)

	set_physics_process(false)

	randomize_appearance()


# ------------------------------------------------------------------
# Randomization
# ------------------------------------------------------------------

func randomize_appearance() -> String:
	var material_nodes: Array[Node2D] = _get_material_nodes()

	if material_nodes.is_empty():
		return ""

	for material_node: Node2D in material_nodes:
		material_node.visible = false

	var chosen_material: Node2D = material_nodes.pick_random()
	chosen_material.visible = true
	current_material = chosen_material.name

	var sprites: Array[Sprite2D] = _get_sprites_of(chosen_material)

	if sprites.is_empty():
		material_assigned.emit(current_material)
		return current_material

	for sprite: Sprite2D in sprites:
		sprite.visible = false

	current_sprite = sprites.pick_random()
	current_sprite.visible = true

	current_sprite.flip_h = randf() < 0.5

	material_assigned.emit(current_material)
	return current_material


func get_material_name() -> String:
	return current_material


func _get_material_nodes() -> Array[Node2D]:
	var result: Array[Node2D] = []

	for child: Node in get_children():
		if child is Area2D:
			continue
		if child is Node2D:
			result.append(child)

	return result


func _get_sprites_of(material_node: Node2D) -> Array[Sprite2D]:
	var result: Array[Sprite2D] = []

	for child: Node in material_node.get_children():
		if child is Sprite2D:
			result.append(child)

	return result


# ------------------------------------------------------------------
# Collection
# ------------------------------------------------------------------

func is_collectable() -> bool:
	return not being_collected


func collect(target_collector: Node2D) -> void:
	if being_collected:
		return

	being_collected = true
	collector = target_collector
	collect_blend = 0.0

	set_physics_process(true)

	# Stop being detectable for pickup.
	var pickup_area: Area2D = get_node_or_null("PickupArea") as Area2D

	if pickup_area != null:
		pickup_area.set_deferred("monitoring", false)
		pickup_area.set_deferred("monitorable", false)

	if collect_tween != null and collect_tween.is_valid():
		collect_tween.kill()

	collect_tween = create_tween()
	collect_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

	# Accelerate into the bag, like a pickup animation.
	collect_tween.set_trans(Tween.TRANS_SINE)
	collect_tween.set_ease(Tween.EASE_IN)

	collect_tween.tween_property(self, "collect_blend", 1.0, collect_time)
	collect_tween.tween_callback(_finish_collection)


func _finish_collection() -> void:
	collected.emit(current_material)
	queue_free()


func _physics_process(delta: float) -> void:
	if not being_collected or collector == null:
		return

	var target: Vector2 = collector.global_position

	if collector.has_method("get_carry_target_position"):
		target = collector.call("get_carry_target_position")

	# Start slow, end fast, same feel as the bag pickup.
	var sharpness := lerpf(4.0, 24.0, collect_blend)
	var weight := 1.0 - exp(-sharpness * delta)

	global_position = global_position.lerp(target, weight)
