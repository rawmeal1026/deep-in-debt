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
		Globals.npc_speech = ["What. You need [color=#98776b]money[/color] or are you just here to stare?",
								"XXXXX",
								"Ah, maybe I can offer you some [color=#98776b]service[/color].",
								"Ya see, I am a [color=#98776b]loan shark[/color], and I have these [color=#98776b]fishes who can't pay[/color] for what they owed.",
								"You can hire them to work for your ocean-cleaning, for all I care. I just need them to get shells from somewhere.",
								"They come in pairs. A [color=#98776b]waste collector[/color] that fills star bags to the brim, and a [color=#98776b]waste hauler[/color] that brings star bags to Mikoi.",
								"I currently have [color=#98776b]3 pairs[/color] of workers. I'm going to need [color=#98776b]100 shells[/color] if you want to rent a pair for a day.",
								"That should free them off their debts.",
								"Come talk to me when you've got the shells. They'll work right away."]
		Globals.player_option_1 = ["I need to clean this town for my brother's party."]
		Globals.player_option_2 = ["I'm bothered with those fishes inside your house."]
		Globals.talk()
		return

	if Globals.shell_count > 99 and worker < 3:
		worker += 1
		Globals.shell_count -= 100
		Globals.spawn_garbage_hauler(get_random_spawn_point())
		Globals.spawn_garbage_collector(get_random_spawn_point())
		if Globals.shell_count < 100 and worker < 3:
			e_button.hide()

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
			if Globals.shell_count < 100 and worker < 3:
				return
			e_button.show()

func end_intro():
	if Globals.shell_count < 100 and worker < 3:
		e_button.hide()
	return

func _on_picass_shark_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.hide()
