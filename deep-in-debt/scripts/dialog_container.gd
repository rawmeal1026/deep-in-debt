extends MarginContainer

## Marker in npc_speech that triggers a player turn. It is NEVER displayed.
@export var player_turn_marker: String = "XXXXX"

@export var type_speed := 30.0

@onready var npc_speech_label: Label = $NPCContainer/SpeechContainer/NinePatchRect/MarginContainer/Panel/Label
@onready var player_option_1_label: Label = $PlayerContainer/SpeechContainer/HBoxContainer/NinePatchRect/MarginContainer/Panel/HBoxContainer/Label
@onready var player_option_2_label: Label = $PlayerContainer/SpeechContainer/HBoxContainer/NinePatchRect3/MarginContainer/Panel/HBoxContainer/Label
@onready var npc_name_label: Label = $NameContainer/NamePanel/HBoxContainer/NinePatchRect2/MarginContainer/CenterContainer/Label

@onready var npc_container: VBoxContainer = $NPCContainer
@onready var player_container: VBoxContainer = $PlayerContainer
@onready var player_name_container: NinePatchRect = $NameContainer/NamePanel/HBoxContainer/NinePatchRect
@onready var npc_name_container: NinePatchRect = $NameContainer/NamePanel/HBoxContainer/NinePatchRect2

# the event paths given by fmod
@export_group("sfx references")
@export var leon_octo : String
@export var mon_whale : String
@export var picass_shark : String
@export var tuna_tello : String
@export var van_gold : String

enum Speaker { NONE, NPC, PLAYER }

var current_speaker: int = Speaker.NONE
var line_index := 0
var player_line_index := 0   # ← which XXXXX / which option pair we're on
var is_typing := false # THIS VARIABLE IS ON WHEN THE TYPING IS ON

var _full_texts: Array[String] = []
var _labels: Array[Label] = []
var _revealed_counts: Array[int] = []

var current_sfx_instance: FmodEvent

func _ready() -> void:
	Globals.initiate_talk.connect(start_dialog)
	visible = false

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
	npc_name_label.text = Globals.npc_name
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
	
	if line_index >= Globals.npc_speech.size():
		end_dialog()
		return
	
	if str(Globals.npc_speech[line_index]) == player_turn_marker:
		player_name_container.show()
		npc_name_container.hide()
		start_player_line()
	else:
		player_name_container.hide()
		npc_name_container.show()
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

	begin_typing([npc_speech_label], [str(Globals.npc_speech[line_index])])


func start_player_line() -> void:
	current_speaker = Speaker.PLAYER

	npc_container.visible = false
	player_container.visible = true

	var texts: Array[String] = ["", ""]
	if player_line_index < Globals.player_option_1.size():
		texts[0] = str(Globals.player_option_1[player_line_index])
	if player_line_index < Globals.player_option_2.size():
		texts[1] = str(Globals.player_option_2[player_line_index])

	begin_typing([player_option_1_label, player_option_2_label], texts)


func end_dialog() -> void:
	current_speaker = Speaker.NONE
	is_typing = false
	set_process(false)
	visible = false
	Globals.in_cutscene = false


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
	if npc_name_container.custom_minimum_size.x != npc_name_label.size.x + 60:
		npc_name_container.custom_minimum_size.x = npc_name_label.size.x + 60

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

	if not is_voice_sound_active() and is_typing:
		trigger_voice_sound()

	if all_done:
		is_typing = false
		set_process(false)


func trigger_voice_sound():
	if is_npc_speaking():
		match Globals.npc_name:
			"Leon Octo":
				current_sfx_instance = Globals.play_fmod_sfx_managed(leon_octo)
			"Mon Whale":
				current_sfx_instance = Globals.play_fmod_sfx_managed(mon_whale)
			"Van Gold":
				current_sfx_instance = Globals.play_fmod_sfx_managed(van_gold)
			"Picass Shark":
				current_sfx_instance = Globals.play_fmod_sfx_managed(picass_shark)
	elif is_player_speaking():
		current_sfx_instance = Globals.play_fmod_sfx_managed(tuna_tello)

func is_voice_sound_active() -> bool:
	if not current_sfx_instance or not current_sfx_instance.is_valid():
		return false
	
	var state = current_sfx_instance.get_playback_state()
	
	# Returns true if active, or false if stopped / finished
	return state != FmodServer.FMOD_STUDIO_PLAYBACK_STOPPED

func check_sfx():
	if current_sfx_instance:
		var state = current_sfx_instance.get_playback_state()
		
		match state:
			FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING:
				print("SFX is actively playing.")
			FmodServer.FMOD_STUDIO_PLAYBACK_STOPPED:
				print("SFX has finished or stopped.")
			FmodServer.FMOD_STUDIO_PLAYBACK_STARTING:
				print("SFX is currently loading/starting.")
			FmodServer.FMOD_STUDIO_PLAYBACK_STOPPING:
				print("SFX is fading out or stopping.")
