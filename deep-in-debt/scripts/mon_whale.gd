extends Node2D

@export var move_time := 1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var spawn_shape: CollisionShape2D = $GarbageBagSpawn/CollisionShape2D

var move_tween: Tween = null


## Called by the player when interact_bag is pressed nearby.
func interact() -> void:
	Globals.spawn_garbage_bag(get_random_spawn_point())

## Returns a random point inside the GarbageBagSpawn shape.
func get_random_spawn_point() -> Vector2:
	var shape := spawn_shape.shape
	var local := Vector2.ZERO

	if shape is RectangleShape2D:
		var rect: RectangleShape2D = shape
		local = Vector2(
			randf_range(-rect.extents.x, rect.extents.x),
			randf_range(-rect.extents.y, rect.extents.y)
		)
	elif shape is CircleShape2D:
		var circle: CircleShape2D = shape
		var angle := randf() * TAU
		var distance := sqrt(randf()) * circle.radius
		local = Vector2(cos(angle), sin(angle)) * distance

	# Use the shape's position so offsets inside the Area2D are respected.
	return spawn_shape.global_position + local
