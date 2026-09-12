extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var e_button: Sprite2D = $E_button
var intro = true

func _ready() -> void:
	animated_sprite_2d.play("Idle")
	Globals.dialog_end.connect(end_intro)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func interact():
	if intro:
		intro = false
		Globals.npc_name = "Carpa Vaggio"
		Globals.npc_speech = ["What. You need money or are you just here to stare?",
								"XXXXX",
								"Ah, maybe I can offer you some service.",
								"Ya see, I am a loan shark, and I have these fishes who can't pay for what they owed.",
								"You can hire them to work for your ocean-cleaning, for all I care. I just need them to get shells from somewhere.",
								"They come in pairs. One waste collector that fills star bags to the brim, and one waste hauler that brings star bags to Mikoi.",
								"I currently have 2 pairs of workers. I'm going to need 200 shells if you want to rent a pair for a day.",
								"That should free them for their debts.",
								"Come talk to me when you've got the shells. They'll work right away."]
		Globals.player_option_1 = ["I need to clean this town for my brother's party."]
		Globals.player_option_2 = ["I'm bothered with those fishes inside your house."]
		Globals.talk()
		return

	if Globals.shell_count > 400:
		Globals.shell_count -= 400
		Globals.objective_3 = true


func _on_carpa_vaggio_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.show()

func end_intro():
	if Globals.shell_count < 200:
		e_button.hide()
	return

func _on_carpa_vaggio_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.hide()
