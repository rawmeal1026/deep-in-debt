class_name CutsceneData
extends Resource

@export var cutscene_name: String = ""
@export var start_position: Vector2 = Vector2.ZERO
@export var end_position: Vector2 = Vector2(1000, 0)
@export var duration: float = 4.0
@export var zoom_start: float = 1.0
@export var zoom_end: float = 1.0
## Seconds to hold on the end frame before the next shot starts.
@export var hold_time: float = 0.0
## If set, this cutscene automatically plays next when this one ends.
@export var next_cutscene: String = ""
