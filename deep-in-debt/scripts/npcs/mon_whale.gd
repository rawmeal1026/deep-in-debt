extends Node2D

@export var move_time := 1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var spawn_shape: CollisionShape2D = $GarbageBagSpawn/CollisionShape2D

var intro = true
var stars_bought = 0

func worker_interact() -> void:
	Globals.spawn_garbage_bag(get_random_spawn_point())

## Called by the player when interact is pressed nearby.
func interact() -> void:
	
	if intro:
		intro = false
		Globals.npc_name = "Mon Whale"
		Globals.npc_speech = ["I like my steak...", "Whale done.", "HAHAHAHAHAHA.", "Laugh or I'll eat you."]
		'''
		Globals.npc_speech = ["The shining stars falling from the sky.",
								"Who would've known even the most beautiful thing can emit such a bad smell?",
								"XXXXX",
								"Because of them, air is slowly becoming dimmer. And day by day, it's getting harder to see.",
								"It's easy to see it as a curse. But I believe our vision is not being erased.",
								"It's being replaced.",
								"We discover more things above the surface. And as time passes by, we see more kind of stars.",
								"I believe time will come where all of us can finally see what's above the surface.",
								"XXXXX",
								"I'm the wise star collector, I forgot to introduce. I give free star containers.",
								"If you fill them up and return it to me, I'll give a shell for each stars you've collected.",
								"I wish your brother a happy birthday party."]
		Globals.player_option_1 = ["They're disgusting. We should stay away from them.", "I don't know about that."]
		Globals.player_option_2 = ["They reek incomprehensible wonders.", "That's a plausible theory."]
		Globals.talk()
		'''
		return

	if not is_instance_valid(Globals.carried_bag):
		Globals.spawn_garbage_bag(get_random_spawn_point())
		return

	# Must be carrying a bag.
	if not is_instance_valid(Globals.carried_bag):
		print("No bag to sell.")
		return

	if Globals.player_garbage_carry_count <= 0:
		print("The bag is empty.")
		return

	# Add one shell per garbage item.
	Globals.shell_count += Globals.player_garbage_carry_count

	if Globals.carried_bag.has_method("drop"):
			Globals.carried_bag.call("drop")
			
	Globals.carried_bag.queue_free()

	# Reset the player's carrying state.
	Globals.carried_bag = null
	Globals.is_player_carrying_a_bag = false
	Globals.player_garbage_carry_count = 0

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
