extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var e_button: Sprite2D = $E_button
var intro = true

func _ready() -> void:
	animated_sprite_2d.play("Idle")
	Globals.dialog_end.connect(end_intro)

func talk():
	if intro:
		intro = false
		Globals.npc_name = "Carpa Vaggio"
		Globals.npc_speech = ["Oh! A visitor. Come closer, dear, let me get a [wave]good look[/wave] at you.",
								"I'm [color=#98776b]Carpa Vaggio[/color]. Some call me the [wave]hottest lady[/wave] in town, hohoho",
								"XXXXX",
								"I'm also the [color=#98776b]head baker[/color] of this town's bakery. I still say I've got a few good years of baking left in these fins.",
								"You caught me at a good time — the ovens are warm and the kitchen smells like something worth staying for.",
								"A cake from me will cost you [color=#98776b]1000 shells[/color]. Quality never comes cheap, sweetheart.",
								"Oh, it's a birthday cake you wish me to create?",
								"You must've started with that, honey. I'll give you a discount. I'll take only [color=#98776b]500 shells[/color] for the cake.",
								"Come back whenever the shell's ready. Granny's not going anywhere."]
		Globals.player_option_1 = ["You're the only lady in this town though."]
		Globals.player_option_2 = ["It's very understandable, ma'am."]
		Globals.talk()
		return

	if Globals.shell_count > 499:
		Globals.shell_count -= 500
		Globals.objective_3 = true

<<<<<<< Updated upstream

func _on_carpa_vaggio_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.show()

func end_intro():
	if Globals.shell_count < 200:
=======
func action():
	print("action")

func end_intro():
	if Globals.shell_count < 500:
>>>>>>> Stashed changes
		e_button.hide()
	return
