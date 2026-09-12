extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var worker_spawn: CollisionShape2D = $WorkerSpawn/CollisionShape2D
@onready var e_button: Sprite2D = $E_button

var intro = true
var worker = 0
func _ready() -> void:
	animated_sprite_2d.play("Idle")
	Globals.dialog_end.connect(end_intro)

func interact():
	if intro:
		intro = false
		Globals.npc_name = "Picass Shark"
		Globals.npc_speech = ["What. You need money or are you just here to stare?",
								"XXXXX",
								"Ah, maybe I can offer you some service.",
								"Ya see, I am a loan shark, and I have these fishes who can't pay for what they owed.",
								"You can hire them to work for your ocean-cleaning, for all I care. I just need them to get shells from somewhere.",
								"They come in pairs. One waste collector that fills star bags to the brim, and one waste hauler that brings star bags to Mikoi.",
								"I currently have 4 pairs of workers. I'm going to need 200 shells if you want to rent a pair for a day.",
								"That should free them for their debts.",
								"Come talk to me when you've got the shells. They'll work right away."]
		Globals.player_option_1 = ["I need to clean this town for my brother's party."]
		Globals.player_option_2 = ["I'm bothered with those fishes inside your house."]
		Globals.talk()
		return

	if Globals.shell_count > 199 and worker < 5:
		worker += 1
		Globals.shell_count -= 200
		Globals.spawn_garbage_hauler(get_random_spawn_point())
		Globals.spawn_garbage_collector(get_random_spawn_point())

## Returns a random point inside the GarbageBagSpawn shape.
func get_random_spawn_point() -> Vector2:
	var shape := worker_spawn.shape
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
	return worker_spawn.global_position + local


func _on_picass_shark_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		if intro:
			e_button.show()
		else:
			if Globals.shell_count < 200:
				return
			e_button.show()

func end_intro():
	if Globals.shell_count < 200:
		e_button.hide()
	return

func _on_picass_shark_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.hide()
