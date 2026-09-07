extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if text != str(Globals.shell_count):
		text = str(Globals.shell_count)
