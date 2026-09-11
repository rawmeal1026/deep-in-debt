extends Node

@onready var tutorial_scene: CanvasLayer = $TutorialScene
@onready var objectives_scene: CanvasLayer = $ObjectivesScene
@onready var trash_meter_scene: CanvasLayer = $TrashMeterScene

var ui_counter = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_ui"):
		ui_counter += 1
		if ui_counter == 4:
			ui_counter = 0
	match ui_counter:
		0:
			tutorial_scene.show()
		1:
			tutorial_scene.hide()
			objectives_scene.show()
		2:
			objectives_scene.hide()
			trash_meter_scene.show()
		3:
			trash_meter_scene.hide()

func _ready() -> void:
	# ... any other setup code you already had ...
	Globals.max_garbage = Globals.get_garbage_count()
	
	# Wait one frame so all nodes and cameras are fully in the tree.
	await get_tree().process_frame

	# Start your cutscene chain (use the exact names from your Cutscenes array).
	Globals.play_cutscene_chain(["Opening1"])
