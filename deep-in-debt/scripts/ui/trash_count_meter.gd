extends TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = 20 + Globals.bag_slow_interval * 4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if value != 15 + Globals.player_garbage_carry_count:
		value = 15 + Globals.player_garbage_carry_count
