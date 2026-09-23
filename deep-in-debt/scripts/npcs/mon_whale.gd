extends Node

@onready var interact: Area2D = $Interact
@onready var label: Label = $Sprite2D/Label
@onready var garbage_bag_spawn: CollisionShape2D = $GarbageBagSpawn/CollisionShape2D
@onready var speech_manager: Node = $SpeechManager
var current_quest = -1
var quest_num = 0

func _ready() -> void:
	Globals.dialog_end.connect(initiate_quest)
	quest_num = speech_manager.get_quest_num()

func action() -> void:
	Globals.spawn_garbage_bag(get_random_spawn_point())

func talk() -> void:
	var finished_quest : int = speech_manager.get_quest_finished()
	if finished_quest > quest_num:
		speech_manager.random_speech()
		return
	if current_quest < finished_quest:
		initiate_quest(finished_quest)
		return
	if current_quest == finished_quest:
		speech_manager.remind_quest()
		return
	if current_quest > finished_quest:
		speech_manager.finish_quest()
		return

func initiate_quest(finished_quest : int):
	speech_manager.start_quest()
	current_quest = finished_quest

## Returns a random point inside the GarbageBagSpawn shape.
func get_random_spawn_point() -> Vector2:
	var shape := garbage_bag_spawn.shape
	var local := Vector2.ZERO

	if shape is RectangleShape2D:
		var rect: RectangleShape2D = shape
		local = Vector2(
			randf_range(-rect.extents.x, rect.extents.x),
			randf_range(-rect.extents.y, rect.extents.y)
		)
	elif shape is CircleShape2D:
		var circle: CircleShape2D = shape
		var angle := randf() * TAU
		var distance := sqrt(randf()) * circle.radius
		local = Vector2(cos(angle), sin(angle)) * distance

	# Use the shape's position so offsets inside the Area2D are respected.
	return garbage_bag_spawn.global_position + local
