class_name Letterbox
extends CanvasLayer
## Cinematic black bars: slide in for cutscenes, slide out afterwards.

signal bars_hidden

@export_range(0.0, 0.5) var bar_fraction := 0.12
@export var slide_in_time := 0.6
@export var slide_out_time := 1.2
@export var bar_color := Color.BLACK

@onready var top_bar: ColorRect = $TopBar
@onready var bottom_bar: ColorRect = $BottomBar

var _shown := false
var _tween: Tween = null


func _ready() -> void:
	layer = 100

	for bar in [top_bar, bottom_bar]:
		bar.color = bar_color
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.set_anchors_preset(Control.PRESET_TOP_LEFT)

	get_viewport().size_changed.connect(_on_size_changed)

	_apply_sizes()
	_snap_hidden()


func show_bars() -> void:
	_shown = true
	_apply_sizes()

	var vp := get_viewport().get_visible_rect().size
	var bar_h := _bar_height()

	_kill_tween()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_parallel(true)
	_tween.tween_property(top_bar, "position", Vector2.ZERO, slide_in_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(bottom_bar, "position", Vector2(0, vp.y - bar_h), slide_in_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func hide_bars() -> void:
	_shown = false
	_apply_sizes()

	var vp := get_viewport().get_visible_rect().size
	var bar_h := _bar_height()

	_kill_tween()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_parallel(true)
	_tween.tween_property(top_bar, "position", Vector2(0, -bar_h), slide_out_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(bottom_bar, "position", Vector2(0, vp.y), slide_out_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.finished.connect(_on_hide_finished, CONNECT_ONE_SHOT)


func _on_hide_finished() -> void:
	bars_hidden.emit()


func _bar_height() -> float:
	return get_viewport().get_visible_rect().size.y * bar_fraction


func _apply_sizes() -> void:
	var vp := get_viewport().get_visible_rect().size
	var bar_h := _bar_height()
	top_bar.size = Vector2(vp.x, bar_h)
	bottom_bar.size = Vector2(vp.x, bar_h)


func _snap_shown() -> void:
	var vp := get_viewport().get_visible_rect().size
	var bar_h := _bar_height()
	top_bar.position = Vector2.ZERO
	bottom_bar.position = Vector2(0, vp.y - bar_h)


func _snap_hidden() -> void:
	var vp := get_viewport().get_visible_rect().size
	var bar_h := _bar_height()
	top_bar.position = Vector2(0, -bar_h)
	bottom_bar.position = Vector2(0, vp.y)


func _on_size_changed() -> void:
	_apply_sizes()
	if _shown:
		_snap_shown()
	else:
		_snap_hidden()


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
