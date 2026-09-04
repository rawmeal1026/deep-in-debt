extends NinePatchRect

@onready var label: Label = $MarginContainer/CenterContainer/Label

func _ready() -> void:
	custom_minimum_size.x = label.size.x + 60
