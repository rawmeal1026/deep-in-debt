extends MarginContainer

var letters_shown := 0
## Marker in npc_speech that triggers a player turn. It is NEVER displayed.
@export var player_turn_marker: String = "XXXXX"


@onready var audio_manager: Node = $"../../../AudioManager"

@export var type_speed := 30.0

@onready var npc_speech_label: Label = $NPCContainer/SpeechContainer/NinePatchRect/MarginContainer/Panel/Label

@export var type_speed := 6
@export var portrait_toggle_interval := 0.15

@onready var audio_manager: Node = $"../../../AudioManager"

@onready var npc_speech_label: RichTextLabel = $NPCContainer/SpeechContainer/NinePatchRect/MarginContainer/Panel/Label
@onready var player_option_1_label: Label = $PlayerContainer/SpeechContainer/HBoxContainer/NinePatchRect/MarginContainer/Panel/HBoxContainer/Label
@onready var player_option_2_label: Label = $PlayerContainer/SpeechContainer/HBoxContainer/NinePatchRect3/MarginContainer/Panel/HBoxContainer/Label
@onready var npc_name_label: Label = $NameContainer/NamePanel/HBoxContainer/NinePatchRect2/MarginContainer/CenterContainer/Label
@onready var progress_bar: ProgressBar = $PlayerContainer/SpeechContainer/HBoxContainer/ProgressBar

@onready var npc_container: VBoxContainer = $NPCContainer
@onready var player_container: VBoxContainer = $PlayerContainer
@onready var player_name_container: NinePatchRect = $NameContainer/NamePanel/HBoxContainer/NinePatchRect
@onready var npc_name_container: NinePatchRect = $NameContainer/NamePanel/HBoxContainer/NinePatchRect2
@onready var player_portrait: TextureRect = $IllusContainer/HBoxContainer/TextureRect
@onready var npc_portrait: TextureRect = $IllusContainer/HBoxContainer/TextureRect2

# the event paths given by fmod
@export_group("sfx references")
@export var leon_octo : String
@export var mon_whale : String
@export var picass_shark : String
@export var tuna_tello : String
@export var van_gold : String
@export var mikoi_angelo : String
@export var carpa_vaggio : String

var npc_portrait_library = {
	"Carpa Vaggio": [preload("res://assets/popart/CarpaVaggio_01.png"), preload("res://assets/popart/CarpaVaggio_02.png")],
	"Mikoi Angelo": [preload("res://assets/popart/MikoiAngelo01.png"), preload("res://assets/popart/MikoiAngelo02.png")],
	"Mon Whale": [preload("res://assets/popart/MonWhale01.png"), preload("res://assets/popart/MonWhale02.png")],
	"Picass Shark": [preload("res://assets/popart/PicassShark01.png"), preload("res://assets/popart/PicassShark02.png")],
	"Leon Octo": [preload("res://assets/popart/TunaTello1.png"), preload("res://assets/popart/TunaTello2.png")]
}

var player_portrait_library = [preload("res://assets/popart/TunaTello1.png"), preload("res://assets/popart/TunaTello2.png")]

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

var current_sfx_instance: FmodEvent

# --- NEW CHOICE VARIABLES ---
var is_choosing := false
var is_speaking_choice := false
var choice_time_left: float = 0.0
var _play_voice_for_typing := true
# ----------------------------

# --- PORTRAIT ANIMATION VARIABLES ---
var current_portrait_frames: Array = []
var portrait_toggle_timer := 0.0
var portrait_frame_index := 0
var active_portrait: TextureRect = null # Tracks which TextureRect is currently animating
# ------------------------------------

var _full_texts: Array[String] = []
var _labels: Array[Control] = []  # Can hold both Label and RichTextLabel
var _revealed_counts: Array[int] = []
var _total_counts: Array[int] = []

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

	# "is_pressed()" means it's a press (not a release).
	# "not event.is_echo()" ensures it doesn't trigger repeatedly if the key is held down.
	if event.is_pressed() and not event.is_echo():
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


	# Ignore "talk" button while the choice timer is running
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

	# Set NPC portrait as active and load frames
	active_portrait = npc_portrait
	current_portrait_frames = npc_portrait_library.get(Globals.npc_name, [])
	_reset_portrait()

	begin_typing([npc_speech_label], [str(Globals.npc_speech[line_index])], true)


func start_player_line() -> void:
	current_speaker = Speaker.NONE # Prevent voice during choice display
	is_choosing = true
	is_speaking_choice = false

	npc_container.visible = false
	player_container.visible = true

	
	# Reset NPC portrait to frame 0, then STOP animation while player chooses
	active_portrait = npc_portrait
	current_portrait_frames = npc_portrait_library.get(Globals.npc_name, [])
	_reset_portrait()
	active_portrait = null # <--- ADD THIS to freeze the portrait

	# Start 10 second timer
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

	# Set Player portrait as active and load frames
	active_portrait = player_portrait
	current_portrait_frames = player_portrait_library
	_reset_portrait()

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
	current_portrait_frames = []
	active_portrait = null
	_reset_portrait()
	set_process(false)
	Globals.dialog_end.emit()
	visible = false
	Globals.in_cutscene = false


# ------------------------------------------------------------------
# Typewriter (BBCode-aware for main speech, regular for options)
# ------------------------------------------------------------------

func begin_typing(labels: Array[Control], texts: Array[String], play_voice: bool = true) -> void:
	_labels = labels
	_full_texts = texts
	_play_voice_for_typing = play_voice

	_revealed_counts = []
	_total_counts = []
	for i in range(texts.size()):
		_revealed_counts.append(0)
		
		if _labels[i] is RichTextLabel:
			# RichTextLabel: set full text, reveal via visible_characters
			_labels[i].text = texts[i]
			_labels[i].visible_characters = 0
			_total_counts.append(_labels[i].get_total_character_count())
		else:
			# Regular Label: start empty, reveal via substr
			_labels[i].text = ""
			_total_counts.append(texts[i].length())

	is_typing = true
	set_process(true)
	if play_voice:
		trigger_voice_sound(0, true)


func finish_typing() -> void:
	for i in range(_labels.size()):
		if _labels[i] is RichTextLabel:
			_labels[i].visible_characters = -1  # -1 = show everything
		else:
			_labels[i].text = _full_texts[i]

	is_typing = false

	# Keep processing if the player is still in the 5-second choice window
	set_process(is_choosing) 
	if _play_voice_for_typing:
		trigger_voice_sound(0, true)

	# Reset portrait to first frame when typing finishes
	_reset_portrait()
	# Keep processing if the player is still in the choice window
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

	# Handle Portrait Animation (Uses active_portrait)
	if is_typing and active_portrait != null and current_portrait_frames.size() >= 2:
		portrait_toggle_timer += _delta
		if portrait_toggle_timer >= portrait_toggle_interval:
			portrait_toggle_timer = 0.0
			portrait_frame_index = 1 - portrait_frame_index  # Toggle between 0 and 1
			if portrait_frame_index < current_portrait_frames.size():
				active_portrait.texture = current_portrait_frames[portrait_frame_index]

	if not is_typing:
		return

	var all_done := true

	for i in range(_full_texts.size()):
		if _revealed_counts[i] < _total_counts[i]:
			_revealed_counts[i] = mini(_revealed_counts[i] + type_speed, _total_counts[i])
			
			if _labels[i] is RichTextLabel:
				_labels[i].visible_characters = _revealed_counts[i]
			else:
				_labels[i].text = _full_texts[i].substr(0, _revealed_counts[i])

		if _revealed_counts[i] < _total_counts[i]:
			all_done = false

	letters_shown = npc_speech_label.text.replace(" ", "").length()
	
	# Only play voice if _play_voice_for_typing is true
	if is_typing and _play_voice_for_typing: #if not is_voice_sound_active() and is_typing and _play_voice_for_typing:
		trigger_voice_sound(letters_shown)

	if not is_voice_sound_active() and is_typing:
		trigger_voice_sound()

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

	# Voice blips: count revealed NON-space characters of the parsed text
	# (parsed text = what the player sees, tags stripped).
	var parsed := npc_speech_label.get_parsed_text()
	var shown := npc_speech_label.visible_characters
	if shown < 0 or shown > parsed.length():
		shown = parsed.length()
	letters_shown = parsed.substr(0, shown).replace(" ", "").length()
	
	# Only play voice if _play_voice_for_typing is true
	if is_typing and _play_voice_for_typing:
		trigger_voice_sound(letters_shown)

	if all_done:
		is_typing = false
		# Reset portrait to first frame when typing finishes
		_reset_portrait()
		# Keep processing if the player is still in the choice window
		set_process(is_choosing)


func _reset_portrait() -> void:
	portrait_toggle_timer = 0.0
	portrait_frame_index = 0
	if active_portrait != null and current_portrait_frames.size() > 0:
		active_portrait.texture = current_portrait_frames[0]


func trigger_voice_sound(letters: int, line_start = false):
	if is_npc_speaking():
		match Globals.npc_name:
			"Leon Octo":
				if letters % 1 == 0 or line_start:
					audio_manager.play_sfx_oneshot("leon_octo")
			"Mon Whale":
				if letters % 6 == 0 or line_start:
					audio_manager.play_sfx_oneshot("mon_whale")
			"Van Gold":
				if letters % 1 == 0 or line_start:
					audio_manager.play_sfx_oneshot("van_gold")
			"Picass Shark":
				if letters % 6 == 0 or line_start:
					audio_manager.play_sfx_oneshot("picass_shark")
			"Carpa Vaggio":
				if letters % 1 == 0 or line_start:
					audio_manager.play_sfx_oneshot("carpa_vaggio")
			"Mikoi Angelo":
				if letters % 1 == 0 or line_start:
					audio_manager.play_sfx_oneshot("mikoi_angelo")
	elif is_player_speaking():
		if letters % 2 == 0 or line_start:
			audio_manager.play_sfx_oneshot("tuna_tello")