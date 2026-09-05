extends MarginContainer

@export var npc_name: String = ""
@export var npc_speech: Array
@export var player_option_1: Array
@export var player_option_2: Array

## Marker in npc_speech that triggers a player turn. It is NEVER displayed.
@export var player_turn_marker: String = "XXXXX"

@export var type_speed := 30.0

@onready var npc_speech_label: Label = $NPCContainer/SpeechContainer/NinePatchRect/MarginContainer/Panel/Label
@onready var player_option_1_label: Label = $PlayerContainer/SpeechContainer/HBoxContainer/NinePatchRect/MarginContainer/Panel/Label
@onready var player_option_2_label: Label = $PlayerContainer/SpeechContainer/HBoxContainer/NinePatchRect2/MarginContainer/Panel/Label
@onready var npc_name_label: Label = $NameContainer/NamePanel/HBoxContainer/NinePatchRect2/MarginContainer/CenterContainer/Label

@onready var npc_container: VBoxContainer = $NPCContainer
@onready var player_container: VBoxContainer = $PlayerContainer

enum Speaker { NONE, NPC, PLAYER }

var current_speaker: int = Speaker.NONE
var line_index := 0
var player_line_index := 0   # ← which XXXXX / which option pair we're on
var is_typing := false

var _full_texts: Array[String] = []
var _labels: Array[Label] = []
var _revealed_counts: Array[int] = []


func _ready() -> void:
	npc_name_label.text = npc_name
	visible = false
	start_dialog()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("talk"):
		advance_dialog()


# ------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------

func start_dialog() -> void:
	line_index = 0
	player_line_index = 0
	visible = true
	show_current_line()


func get_current_speaker() -> int:
	return current_speaker


func is_npc_speaking() -> bool:
	return current_speaker == Speaker.NPC


func is_player_speaking() -> bool:
	return current_speaker == Speaker.PLAYER


# ------------------------------------------------------------------
# Flow
# ------------------------------------------------------------------

## Shows the entry at line_index:
## a normal NPC line, or a player turn if the entry is the marker.
func show_current_line() -> void:
	if line_index >= npc_speech.size():
		end_dialog()
		return

	if str(npc_speech[line_index]) == player_turn_marker:
		# The NPC never "says" the marker; the player takes over instead.
		start_player_line()
	else:
		start_npc_line()


func advance_dialog() -> void:
	if is_typing:
		finish_typing()
		return

	if is_player_speaking():
		player_line_index += 1

	line_index += 1
	show_current_line()


func start_npc_line() -> void:
	current_speaker = Speaker.NPC

	npc_container.visible = true
	player_container.visible = false

	begin_typing([npc_speech_label], [str(npc_speech[line_index])])


func start_player_line() -> void:
	current_speaker = Speaker.PLAYER

	npc_container.visible = false
	player_container.visible = true

	var texts: Array[String] = ["", ""]
	if player_line_index < player_option_1.size():
		texts[0] = str(player_option_1[player_line_index])
	if player_line_index < player_option_2.size():
		texts[1] = str(player_option_2[player_line_index])

	begin_typing([player_option_1_label, player_option_2_label], texts)


func end_dialog() -> void:
	current_speaker = Speaker.NONE
	is_typing = false
	set_process(false)
	visible = false


# ------------------------------------------------------------------
# Typewriter
# ------------------------------------------------------------------

func begin_typing(labels: Array[Label], texts: Array[String]) -> void:
	_labels = labels
	_full_texts = texts

	_revealed_counts = []
	for i in range(texts.size()):
		_revealed_counts.append(0)
		_labels[i].text = ""

	is_typing = true
	set_process(true)


func finish_typing() -> void:
	for i in range(_full_texts.size()):
		_labels[i].text = _full_texts[i]

	is_typing = false
	set_process(false)


func _process(delta: float) -> void:
	if not is_typing:
		return

	var all_done := true

	for i in range(_full_texts.size()):
		if _revealed_counts[i] < _full_texts[i].length():
			_revealed_counts[i] = mini(
				_revealed_counts[i] + int(type_speed * delta) + 1,
				_full_texts[i].length()
			)
			_labels[i].text = _full_texts[i].substr(0, _revealed_counts[i])

		if _revealed_counts[i] < _full_texts[i].length():
			all_done = false

	if all_done:
		is_typing = false
		set_process(false)
