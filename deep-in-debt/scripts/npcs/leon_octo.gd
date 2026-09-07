extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var intro = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("Idle")

func interact():
	if intro:
		intro = false
		Globals.npc_name = "Leon Octo"
		Globals.npc_speech = ["Ah, Tuna Tello. No need to explain — I already know why you're here.",
								"Van Gold's birthday is coming, isn't it? And you're planning a surprise party for him.",
								"XXXXX",
								"You'll want gift wrappers first. For that, bring me 25 paper boards.",
								"Remember, they must be polished by Mikoi Angelo before you bring them here. Only then will the wrappers come out in top condition.",
								"Once you have them polished, bring them to me along with a fee of 20 shells, and I'll have your gift wrappers ready."]
		Globals.player_option_1 = ["How can you even know that?"]
		Globals.player_option_2 = ["Wow! You're so smart, Leon."]
		Globals.talk()
		return
	
