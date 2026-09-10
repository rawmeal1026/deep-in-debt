extends NinePatchRect

@onready var h_box_container: HBoxContainer = $"../../../../HBoxContainer/VBoxContainer/HBoxContainer2/CenterContainer/HBoxContainer"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if custom_minimum_size.x != h_box_container.size.x + 45:
		custom_minimum_size.x = h_box_container.size.x + 45
