extends Area2D

@export var actor : Node2D
@export var actor_name : String
@export var label: Label

var groups_inside : Array[String] = []

func _on_area_entered(area: Area2D) -> void:
	var area_groups = area.get_groups()
	for group in area_groups:
		groups_inside.append(group)

func _on_area_exited(area: Area2D) -> void:
	var area_groups = area.get_groups()
	for group in area_groups:
		if group in groups_inside:
			groups_inside.erase(group)

func trigger_talk():
	actor.talk()

func trigger_action():
	actor.action()
