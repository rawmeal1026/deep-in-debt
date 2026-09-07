extends TextureRect

var atlas = preload("res://assets/tilesets/player_slow_meter.png")
var icon := AtlasTexture.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not Globals.is_player_carrying_a_bag:
		icon.atlas = atlas
		icon.region = Rect2(0, 0, 80, 81)
	elif Globals.player_garbage_carry_count < 1:
		icon.atlas = atlas
		icon.region = Rect2(80, 0, 80, 81)
	elif Globals.player_garbage_carry_count < (Globals.bag_slow_interval * 2):
		icon.atlas = atlas
		icon.region = Rect2(160, 0, 80, 81)
	elif Globals.player_garbage_carry_count < (Globals.bag_slow_interval * 3):
		icon.atlas = atlas
		icon.region = Rect2(240, 0, 80, 81)
	elif Globals.player_garbage_carry_count < (Globals.bag_slow_interval * 4):
		icon.atlas = atlas
		icon.region = Rect2(320, 0, 80, 81)

	texture = icon
