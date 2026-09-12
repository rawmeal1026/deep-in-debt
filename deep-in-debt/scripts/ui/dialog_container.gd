extends MarginContainer

var letters_shown := 0
## Marker in npc_speech that triggers a player turn. It is NEVER displayed.
@export var player_turn_marker: String = "XXXXX"

@export var type_speed := 3

@onready var audio_manager: Node = $"../../../AudioManager"


@onready var npc_speech_label: Label = $NPCContainer/SpeechContainer/NinePatchRect/MarginContainer/Panel/Label
@onready var player_option_1_label: Label = $PlayerContainer/SpeechContainer/HBoxContainer/NinePatchRect/MarginContainer/Panel/HBoxContainer/Label
@onready var player_option_2_label: Label = $PlayerContainer/SpeechContainer/HBoxContainer/NinePatchRect3/MarginContainer/Panel/HBoxContainer/Label
@onready var npc_name_label: Label = $NameContainer/NamePanel/HBoxContainer/NinePatchRect2/MarginContainer/CenterContainer/Label
@onready var progress_bar: ProgressBar = $PlayerContainer/SpeechContainer/HBoxContainer/ProgressBar

@onready var npc_container: VBoxContainer = $NPCContainer
@onready var player_container: VBoxContainer = $PlayerContainer
@onready var player_name_container: NinePatchRect = $NameContainer/NamePanel/HBoxContainer/NinePatchRect
@onready var npc_name_container: NinePatchRect = $NameContainer/NamePanel/HBoxContainer/NinePatchRect2
@onready var player_portrait: TextureRect = $IllusContainer/HBoxContainer/TextureRect

# the event paths given by fmod
@export_group("sfx references")
@export var leon_octo : String
@export var mon_whale : String
@export var picass_shark : String
@export var tuna_tello : String
@export var van_gold : String
@export var mikoi_angelo : String
@export var carpa_vaggio : String

enum Speaker { NONE, NPC, PLAYER }
var player_sprites = [preload("res://assets/popart/TunaTello1.png"), preload("res://assets/popart/TunaTello2.png")]
var shark_sprites = [preload("res://assets/popart/PicassShark01.png"), preload("res://assets/popart/PicassShark02.png")]
var current_speaker: int = Speaker.NONE
var line_index := 0
var player_line_index := 0   # ← which XXXXX / which option pair we're on
var is_typing := false # THIS VARIABLE IS ON WHEN THE TYPING IS ON

# --- NEW CHOICE VARIABLES ---
var is_choosing := false
var is_speaking_choice := false
var choice_time_left: float = 0.0
var _play_voice_for_typing := true
# ----------------------------

var _full_texts: Array[String] = []
var _labels: Array[Label] = []
var _revealed_counts: Array[int] = []

#var current_sfx_instance: FmodEvent

func _ready() -> void:
	Globals.initiate_talk.connect(start_dialog)
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	# Handle Choice Selection
	if is_choosing:
		if event.is_action_pressed("move_left"):
			select_choice(0)
			get_viewport().set_input_as_handled()
			return
		elif event.is_action_pressed("move_right"):
			select_choice(1)
			get_viewport().set_input_as_handled()
			return

	if event.is_pressed():
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

	# Ignore "talk" button while the 5s choice timer is running
	if is_choosing:
		return

	# If we just finished speaking the chosen option, advance to next line
	if is_speaking_choice:
		is_speaking_choice = false
		player_line_index += 1
		line_index += 1
		show_current_line()
		return

	if is_player_speaking():
		player_line_index += 1

	line_index += 1
	show_current_line()


func start_npc_line() -> void:
	current_speaker = Speaker.NPC

	npc_container.visible = true
	player_container.visible = false
	progress_bar.visible = false

	begin_typing([npc_speech_label], [str(Globals.npc_speech[line_index])], true)


func start_player_line() -> void:
	current_speaker = Speaker.NONE # Prevent voice during choice display
	is_choosing = true
	is_speaking_choice = false

	npc_container.visible = false
	player_container.visible = true
	
	# Start 5 second timer
	progress_bar.visible = true
	progress_bar.value = 100.0
	choice_time_left = 10.0

	var texts: Array[String] = ["", ""]
	if player_line_index < Globals.player_option_1.size():
		texts[0] = str(Globals.player_option_1[player_line_index])
	if player_line_index < Globals.player_option_2.size():
		texts[1] = str(Globals.player_option_2[player_line_index])

	# Pass 'false' so Tuna Tello doesn't speak while options are typing
	begin_typing([player_option_1_label, player_option_2_label], texts, false)


func select_choice(option_index: int) -> void:
	is_choosing = false
	progress_bar.visible = false
	is_typing = false
	set_process(false)

	var chosen_text := ""
	if option_index == 0 and player_line_index < Globals.player_option_1.size():
		chosen_text = str(Globals.player_option_1[player_line_index])
	elif option_index == 1 and player_line_index < Globals.player_option_2.size():
		chosen_text = str(Globals.player_option_2[player_line_index])

	if chosen_text == "":
		timeout_choice()
		return

	# Show the chosen text in the main NPC speech label
	npc_container.visible = true
	player_container.visible = false
	player_name_container.show()
	npc_name_container.hide()

	current_speaker = Speaker.PLAYER # Activates Tuna Tello voice
	is_speaking_choice = true

	begin_typing([npc_speech_label], [chosen_text], true)


func timeout_choice() -> void:
	is_choosing = false
	progress_bar.visible = false
	is_typing = false
	set_process(false)
	player_container.visible = false

	# Proceed to next line as usual without speaking a choice
	player_line_index += 1
	line_index += 1
	show_current_line()


func end_dialog() -> void:
	current_speaker = Speaker.NONE
	is_typing = false
	is_choosing = false
	is_speaking_choice = false
	progress_bar.visible = false
	set_process(false)
	Globals.dialog_end.emit()
	visible = false
	Globals.in_cutscene = false


# ------------------------------------------------------------------
# Typewriter
# ------------------------------------------------------------------

func begin_typing(labels: Array[Label], texts: Array[String], play_voice: bool = true) -> void:
	_labels = labels
	_full_texts = texts
	_play_voice_for_typing = play_voice

	_revealed_counts = []
	for i in range(texts.size()):
		_revealed_counts.append(0)
		_labels[i].text = ""

	is_typing = true
	set_process(true)
	if play_voice:
		trigger_voice_sound(0, true)


func finish_typing() -> void:
	for i in range(_full_texts.size()):
		_labels[i].text = _full_texts[i]

	is_typing = false
	# Keep processing if the player is still in the 5-second choice window
	set_process(is_choosing) 
	if _play_voice_for_typing:
		trigger_voice_sound(0, true)

func _process(_delta: float) -> void:
	if npc_name_container.custom_minimum_size.x != npc_name_label.size.x + 60:
		npc_name_container.custom_minimum_size.x = npc_name_label.size.x + 60

	# Handle Choice Timer
	if is_choosing:
		choice_time_left -= _delta
		if choice_time_left <= 0.0:
			choice_time_left = 0.0
			timeout_choice()
			return
			
		progress_bar.value = (choice_time_left / 10.0) * 100.0

	if not is_typing:
		return

	var all_done := true

	for i in range(_full_texts.size()):
		if _revealed_counts[i] < _full_texts[i].length():
			_revealed_counts[i] = mini(
				_revealed_counts[i] + type_speed,
				_full_texts[i].length()
			)
			_labels[i].text = _full_texts[i].substr(0, _revealed_counts[i])

		if _revealed_counts[i] < _full_texts[i].length():
			all_done = false

	letters_shown = npc_speech_label.text.replace(" ", "").length()
	
	# Only play voice if _play_voice_for_typing is true
	if is_typing and _play_voice_for_typing: #if not is_voice_sound_active() and is_typing and _play_voice_for_typing:
		trigger_voice_sound(letters_shown)

	if all_done:
		is_typing = false
		# Keep processing if the player is still in the 5-second choice window
		set_process(is_choosing)


func trigger_voice_sound(letters: int, line_start = false):
	if is_npc_speaking():
		match Globals.npc_name:
			"Leon Octo":
				if letters % 6 == 0 or line_start:
					audio_manager.play_sfx_oneshot("leon_octo")
			"Mon Whale":
				if letters % 7 == 0 or line_start:
					audio_manager.play_sfx_oneshot("mon_whale")
			"Van Gold":
				if letters % 4 == 0 or line_start:
					audio_manager.play_sfx_oneshot("van_gold")
			"Picass Shark":
				if letters % 6 == 0 or line_start:
					audio_manager.play_sfx_oneshot("picass_shark")
			"Carpa Vaggio":
				if letters % 6 == 0 or line_start:
					audio_manager.play_sfx_oneshot("carpa_vaggio")
			"Mikoi Angelo":
				if letters % 7 == 0 or line_start:
					audio_manager.play_sfx_oneshot("mikoi_angelo")
	elif is_player_speaking():
		if letters % 7 == 0 or line_start:
			audio_manager.play_sfx_oneshot("tuna_tello")

'''func is_voice_sound_active() -> bool:
	if not current_sfx_instance or not current_sfx_instance.is_valid():
		return false
	
	var state = current_sfx_instance.get_playback_state()
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
'''
