extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if text != str(Globals.metal_count):
		text = str(Globals.metal_count)
