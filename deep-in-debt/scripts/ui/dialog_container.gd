extends MarginContainer

var letters_shown := 0
## Marker in npc_speech that triggers a player turn. It is NEVER displayed.
@export var player_turn_marker: String = "XXXXX"

@export var type_speed := 6
@export var portrait_toggle_interval := 0.15
<<<<<<< Updated upstream
=======
@export var illustration_fade_time := 0.4
@export var dialog_fade_time := 0.3
>>>>>>> Stashed changes

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
var player_line_index := 0
var is_typing := false

var is_choosing := false
var is_speaking_choice := false
var choice_time_left: float = 0.0
var _play_voice_for_typing := true

var _full_texts: Array[String] = []
var _labels: Array[Control] = []
var _revealed_counts: Array[int] = []

var current_portrait_frames: Array = []
var portrait_toggle_timer := 0.0
var portrait_frame_index := 0
var active_portrait: TextureRect = null

<<<<<<< Updated upstream
=======
var _current_drawing_index := -1
var _fade_tween: Tween = null
var _dialog_fade_tween: Tween = null

>>>>>>> Stashed changes
var _total_counts: Array[int] = []

func _ready() -> void:
	Globals.initiate_talk.connect(start_dialog)
	
	# Start hidden. Alpha at 1.0 because non-drawing-7 dialogs skip the fade
	# and just snap visible, so they need the alpha already at full.
	visible = false
	modulate.a = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if is_choosing:
		if event.is_action_pressed("move_left"):
			select_choice(0)
			get_viewport().set_input_as_handled()
			return
		elif event.is_action_pressed("move_right"):
			select_choice(1)
			get_viewport().set_input_as_handled()
			return

	if event.is_pressed() and not event.is_echo():
		advance_dialog()


# ------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------

func start_dialog() -> void:
	line_index = 0
	player_line_index = 0
	
	# Only fade at drawing 7; otherwise snap visible
	if Globals.drawing == 7:
		_fade_dialog_in()
	else:
		_kill_dialog_tween()
		modulate.a = 1.0
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
<<<<<<< Updated upstream
=======
	update_drawing_state()

>>>>>>> Stashed changes
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

	if is_choosing:
		return

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

	active_portrait = npc_portrait
	current_portrait_frames = npc_portrait_library.get(Globals.npc_name, [])
	_reset_portrait()

	begin_typing([npc_speech_label], [str(Globals.npc_speech[line_index])], true)


func start_player_line() -> void:
	current_speaker = Speaker.NONE
	is_choosing = true
	is_speaking_choice = false

	npc_container.visible = false
	player_container.visible = true
	
	active_portrait = npc_portrait
	current_portrait_frames = npc_portrait_library.get(Globals.npc_name, [])
	_reset_portrait()
	active_portrait = null

	progress_bar.visible = true
	progress_bar.value = 100.0
	choice_time_left = 10.0

	var texts: Array[String] = ["", ""]
	if player_line_index < Globals.player_option_1.size():
		texts[0] = str(Globals.player_option_1[player_line_index])
	if player_line_index < Globals.player_option_2.size():
		texts[1] = str(Globals.player_option_2[player_line_index])

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

	npc_container.visible = true
	player_container.visible = false
	player_name_container.show()
	npc_name_container.hide()

	current_speaker = Speaker.PLAYER
	is_speaking_choice = true

<<<<<<< Updated upstream
	# Set Player portrait as active and load frames
=======
	update_drawing_state()

>>>>>>> Stashed changes
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

	player_line_index += 1
	line_index += 1
	show_current_line()

func end_dialog() -> void:
	current_speaker = Speaker.NONE
	is_typing = false
	is_choosing = false
	is_speaking_choice = false
	progress_bar.visible = false
<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes
	current_portrait_frames = []
	active_portrait = null
	_reset_portrait()
	set_process(false)
<<<<<<< Updated upstream
	Globals.dialog_end.emit()
	visible = false
	Globals.in_cutscene = false
=======

	if Globals.drawing >= 7:
		Globals.in_cutscene = false

	if Globals.drawing == 7:
		_sync_illustration_for_drawing()
		_fade_dialog_out()
	else:
		_kill_dialog_tween()
		visible = false
		modulate.a = 1.0
		Globals.dialog_end.emit()
		_sync_illustration_for_drawing()

func _sync_illustration_for_drawing() -> void:
	if Globals.drawing == 7:
		# Cutscene: no illustration board
		if illustration_board.visible or illustration_color_rect.visible:
			_fade_illustration_out()
		_current_drawing_index = -1
		player_portrait.visible = true
		npc_portrait.visible = true
	elif Globals.drawing >= 8:
		# Epilogue: show illustration (last image), hide portraits
		player_portrait.visible = false
		npc_portrait.visible = false
		var img_index = illustration_board_library.size() - 1
		var target_texture = illustration_board_library[img_index]
		if _current_drawing_index == -1 or illustration_board.texture != target_texture:
			_current_drawing_index = img_index
			illustration_board.texture = target_texture
			_fade_illustration_in()
	# For drawings 0-6 the freshly-started dialog manages the board itself.

# ------------------------------------------------------------------
# Dialog Container Fading (only used at Globals.drawing == 7)
# ------------------------------------------------------------------

func _fade_dialog_in() -> void:
	_kill_dialog_tween()
	visible = true
	modulate.a = 0.0
	
	_dialog_fade_tween = create_tween()
	_dialog_fade_tween.tween_property(self, "modulate:a", 1.0, dialog_fade_time)


func _fade_dialog_out() -> void:
	_kill_dialog_tween()
	
	_dialog_fade_tween = create_tween()
	_dialog_fade_tween.tween_property(self, "modulate:a", 0.0, dialog_fade_time)
	_dialog_fade_tween.tween_callback(_on_dialog_fade_out_complete)


func _on_dialog_fade_out_complete() -> void:
	visible = false
	modulate.a = 1.0   # reset for next non-fade show
	Globals.dialog_end.emit()


func _kill_dialog_tween() -> void:
	if _dialog_fade_tween != null and _dialog_fade_tween.is_valid():
		_dialog_fade_tween.kill()
	_dialog_fade_tween = null


# ------------------------------------------------------------------
# Illustration Board & Visibility Logic (with fades)
# ------------------------------------------------------------------
func update_drawing_state() -> void:
	if Globals.drawing == 7:
		# Cutscene: illustration hidden, portraits shown
		if illustration_board.visible or illustration_color_rect.visible:
			_fade_illustration_out()
		_current_drawing_index = -1
		player_portrait.visible = true
		npc_portrait.visible = true
		return

	# Drawing 0-6 and 8+: illustration mode, portraits off
	player_portrait.visible = false
	npc_portrait.visible = false

	# Map drawing to illustration index.
	# For the epilogue (drawing 8), use the last image in the library.
	var img_index = Globals.drawing
	if Globals.drawing >= 8:
		img_index = illustration_board_library.size() - 1

	if img_index < 0 or img_index >= illustration_board_library.size():
		img_index = -1

	var target_texture = null
	if img_index >= 0:
		target_texture = illustration_board_library[img_index]

	if _current_drawing_index == -1:
		_current_drawing_index = img_index
		if target_texture != null:
			illustration_board.texture = target_texture
		_fade_illustration_in()
		
	elif target_texture != illustration_board.texture:
		_current_drawing_index = img_index
		if target_texture != null:
			_fade_swap_illustration(target_texture)
		else:
			_fade_illustration_out()

func _kill_fade_tween() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null


func _fade_illustration_in() -> void:
	_kill_fade_tween()
	illustration_board.visible = true
	illustration_color_rect.visible = true
	illustration_board.modulate.a = 0.0

	_fade_tween = create_tween()
	_fade_tween.tween_property(illustration_board, "modulate:a", 1.0, illustration_fade_time)


func _fade_illustration_out() -> void:
	_kill_fade_tween()
	_fade_tween = create_tween()
	_fade_tween.tween_property(illustration_board, "modulate:a", 0.0, illustration_fade_time)
	_fade_tween.tween_callback(_hide_illustration_nodes)


func _fade_swap_illustration(new_texture: Texture2D) -> void:
	_kill_fade_tween()
	_fade_tween = create_tween()
	_fade_tween.tween_property(illustration_board, "modulate:a", 0.0, illustration_fade_time)
	_fade_tween.tween_callback(func(): illustration_board.texture = new_texture)
	_fade_tween.tween_property(illustration_board, "modulate:a", 1.0, illustration_fade_time)


func _hide_illustration_nodes() -> void:
	illustration_board.visible = false
	illustration_color_rect.visible = false
>>>>>>> Stashed changes


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
			_labels[i].text = texts[i]
			_labels[i].visible_characters = 0
			_total_counts.append(_labels[i].get_total_character_count())
		else:
			_labels[i].text = ""
			_total_counts.append(texts[i].length())

	is_typing = true
	set_process(true)
	if play_voice:
		trigger_voice_sound(0, true)


func finish_typing() -> void:
	for i in range(_labels.size()):
		if _labels[i] is RichTextLabel:
			_labels[i].visible_characters = -1
		else:
			_labels[i].text = _full_texts[i]

	is_typing = false
	
	_reset_portrait()
	
	set_process(is_choosing) 
	
	if _play_voice_for_typing:
		trigger_voice_sound(0, true)


func _process(_delta: float) -> void:
	if npc_name_container.custom_minimum_size.x != npc_name_label.size.x + 60:
		npc_name_container.custom_minimum_size.x = npc_name_label.size.x + 60

	if is_choosing:
		choice_time_left -= _delta
		if choice_time_left <= 0.0:
			choice_time_left = 0.0
			timeout_choice()
			return
			
		progress_bar.value = (choice_time_left / 10.0) * 100.0

	if is_typing and active_portrait != null and current_portrait_frames.size() >= 2:
		portrait_toggle_timer += _delta
		if portrait_toggle_timer >= portrait_toggle_interval:
			portrait_toggle_timer = 0.0
			portrait_frame_index = 1 - portrait_frame_index
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

	var parsed := npc_speech_label.get_parsed_text()
	var shown := npc_speech_label.visible_characters
	if shown < 0 or shown > parsed.length():
		shown = parsed.length()
	letters_shown = parsed.substr(0, shown).replace(" ", "").length()
	
	if is_typing and _play_voice_for_typing and not is_voice_sound_active():
		trigger_voice_sound(letters_shown)

	if all_done:
		is_typing = false
		_reset_portrait()
		set_process(is_choosing)


func is_voice_sound_active() -> bool:
	var node_name := ""
	if is_npc_speaking():
		match Globals.npc_name:
			"Leon Octo": node_name = "leon_octo"
			"Mon Whale": node_name = "mon_whale"
			"Van Gold": node_name = "van_gold"
			"Picass Shark": node_name = "picass_shark"
			"Carpa Vaggio": node_name = "carpa_vaggio"
			"Mikoi Angelo": node_name = "mikoi_angelo"
	elif is_player_speaking():
		node_name = "tuna_tello"
		
	if node_name == "":
		return false
		
	var sfx_player = audio_manager.get(node_name)
	if sfx_player is AudioStreamPlayer:
		return sfx_player.playing
		
	return false


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


func _reset_portrait() -> void:
	portrait_toggle_timer = 0.0
	portrait_frame_index = 0
	if active_portrait != null and current_portrait_frames.size() > 0:
		active_portrait.texture = current_portrait_frames[0]
