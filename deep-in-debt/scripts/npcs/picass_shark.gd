extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("Idle")

func talk():
	Globals.npc_name = "Picass Shark"
	Globals.npc_speech = ["Hello, Baby girl.", "XXXXX", "Oh no, my name is Sharken Hawking.", "Do you wish to enter my house?", "XXXXX", "Too bad."]
	Globals.player_option_1 = ["Drake?", "Oh hell nah"]
	Globals.player_option_2 = ["Epstein?", "AYOOO, POLICE OFFICER! OVER HERE!"]
	Globals.talk()
