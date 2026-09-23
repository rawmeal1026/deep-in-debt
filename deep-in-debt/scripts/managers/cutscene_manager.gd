extends Node

signal cutscene_finished(cutscene_name: String)
signal chain_finished

@export var cutscenes: Array[CutsceneData]
@export var player_camera_group: String = "player_camera"

var letterbox: Letterbox = null
var cutscene_camera: Camera2D = null
var player_camera: Camera2D = null
var current_data: CutsceneData = null
var is_playing := false
var _queue: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	cutscene_camera = get_node_or_null("CutsceneCamera") as Camera2D
	if cutscene_camera == null:
		push_warning("CutsceneManager: CutsceneCamera child not found - creating one in code.")
		cutscene_camera = Camera2D.new()
		cutscene_camera.name = "CutsceneCamera"
		add_child(cutscene_camera)

	cutscene_camera.enabled = true


func play_cutscene(cutscene_name: String) -> void:
	if is_playing:
		return
	play_cutscene_chain([cutscene_name])


func play_cutscene_chain(names: Array[String]) -> void:
	if is_playing or names.is_empty():
		return

	_queue = names.duplicate()
	var first: String = _queue.pop_front()
	var data := find_cutscene(first)

	if data == null:
		push_warning("CutsceneManager: no cutscene named '" + first + "'")
		return

	player_camera = get_tree().get_first_node_in_group(player_camera_group) as Camera2D
	is_playing = true
	Globals.in_cutscene = true

	var lb := get_letterbox()
	if lb != null:
		lb.show_bars()

	start_cutscene(data)


func queue_cutscene(cutscene_name: String) -> void:
	_queue.append(cutscene_name)


func start_cutscene(data: CutsceneData) -> void:
	current_data = data

	cutscene_camera.enabled = true

	if not cutscene_camera.is_inside_tree():
		push_warning("CutsceneManager: camera not in tree yet - waiting one frame.")
		await get_tree().process_frame

	cutscene_camera.global_position = data.start_position
	cutscene_camera.zoom = Vector2(data.zoom_start, data.zoom_start)
	cutscene_camera.make_current()

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(cutscene_camera, "global_position", data.end_position, data.duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(cutscene_camera, "zoom", \
		Vector2(data.zoom_end, data.zoom_end), data.duration)

	if data.hold_time > 0.0:
		tween.tween_interval(data.hold_time)

	tween.tween_callback(finish_cutscene)


func finish_cutscene() -> void:
	var cname := current_data.cutscene_name
	cutscene_finished.emit(cname)

	var next_name := ""
	if _queue.size() > 0:
		next_name = _queue.pop_front()
	elif current_data.next_cutscene != "":
		next_name = current_data.next_cutscene

	var next_data: CutsceneData = null
	if next_name != "":
		next_data = find_cutscene(next_name)

	if next_data != null:
		start_cutscene(next_data)
		return

	# Chain over: player camera returns now, but in_cutscene stays true
	# until the bars finish sliding out (bars_hidden clears it).
	if player_camera != null:
		player_camera.make_current()

	var lb := get_letterbox()
	if lb != null:
		lb.hide_bars()
	else:
		Globals.in_cutscene = false

	is_playing = false
	current_data = null
	chain_finished.emit()


func _on_bars_hidden() -> void:
	Globals.in_cutscene = false


func find_cutscene(cutscene_name: String) -> CutsceneData:
	for entry in cutscenes:
		if entry != null and entry.cutscene_name == cutscene_name:
			return entry
	return null


func get_letterbox() -> Letterbox:
	if letterbox != null:
		return letterbox

	letterbox = get_node_or_null("Letterbox") as Letterbox

	if letterbox == null and get_tree().current_scene != null:
		letterbox = get_tree().current_scene.find_child("Letterbox", true, false) as Letterbox

	if letterbox == null:
		letterbox = _search_by_type(get_tree().root)

	if letterbox == null:
		push_warning("CutsceneManager: no Letterbox node found in the scene.")
	elif not letterbox.bars_hidden.is_connected(_on_bars_hidden):
		letterbox.bars_hidden.connect(_on_bars_hidden)

	return letterbox


func _search_by_type(node: Node) -> Letterbox:
	var found := node as Letterbox
	if found != null:
		return found
	for child in node.get_children():
		found = _search_by_type(child)
		if found != null:
			return found
	return null
