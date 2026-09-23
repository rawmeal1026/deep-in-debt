extends CanvasLayer

@export var fade_time := 0.3 # Adjust this in the Inspector to make it faster/slower

@onready var label: RichTextLabel = $TalkScreen/Panel/DialogContainer/HBoxContainer/NPCContainer/SpeechContainer/NinePatchRect/MarginContainer/Panel/Label
@onready var talk_screen: Control = $TalkScreen # We target the root UI container to fade it

var _fade_tween: Tween = null

func _ready() -> void:
	Globals.npc_in.connect(show_canvas)
	Globals.npc_out.connect(hide_canvas)
	
	# Start completely hidden and transparent
	talk_screen.modulate.a = 0.0
	hide()

func _process(_delta: float) -> void:
	if label.text != Globals.npc_name:
		label.text = Globals.npc_name

func show_canvas():
	_kill_tween()
	
	# Make the layer visible so we can see the fade happen
	show() 
	talk_screen.modulate.a = 0.0 # Start fully transparent
	
	_fade_tween = create_tween()
	_fade_tween.tween_property(talk_screen, "modulate:a", 1.0, fade_time)

func hide_canvas():
	_kill_tween()
	
	_fade_tween = create_tween()
	_fade_tween.tween_property(talk_screen, "modulate:a", 0.0, fade_time)
	
	# Wait until the fade is completely finished, THEN hide the layer
	# (This prevents the invisible UI from accidentally blocking mouse clicks!)
	_fade_tween.tween_callback(hide) 

func _kill_tween() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null
