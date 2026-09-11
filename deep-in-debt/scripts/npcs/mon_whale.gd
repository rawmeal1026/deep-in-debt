extends Node2D

@export var move_time := 1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var spawn_shape: CollisionShape2D = $GarbageBagSpawn/CollisionShape2D
@onready var e_button: Sprite2D = $E_button


var intro = true

func worker_interact() -> void:
	Globals.spawn_garbage_bag(get_random_spawn_point())

## Called by the player when interact is pressed nearby.
func interact() -> void:
	
	if intro:
		intro = false
		Globals.npc_name = "Mon Whale"
		Globals.npc_speech = ["The shining stars falling from the sky.",
								"Who would've known even the most beautiful thing can emit such a bad smell?",
								"XXXXX",
								"Because of them, air is slowly becoming dimmer. And day by day, it's getting harder to see.",
								"I give free star containers. These stars need to go somewhere other than just lying on the oceanfloor.",
								"Seeing you wish to give your brother a decent party here, I suggest you start cleaning now.",
								"Interact with the bags to either pick them up or drop them down.",
								"Be careful filling the bags with too much stars, as it will significantly slow you down.",
								"I wish your brother a happy birthday."]
		Globals.player_option_1 = ["They're disgusting. We should stay away from them."]
		Globals.player_option_2 = ["They reek incomprehensible wonders."]
		Globals.talk()
		return

	if not is_instance_valid(Globals.carried_bag):
		Globals.spawn_garbage_bag(get_random_spawn_point())
		return

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

func _on_mon_whale_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.show()

func _on_mon_whale_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.hide()
