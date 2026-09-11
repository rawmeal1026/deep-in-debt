extends Camera2D

@export var player_path: NodePath
@export var deadzone_radius := 120.0
@export var follow_sharpness := 5.0

var player: CharacterBody2D


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	make_current()

	# Engine-enforced border: the camera view can never show outside this.
	var border := Globals.world_border
	limit_left = int(border.position.x)
	limit_top = int(border.position.y)
	limit_right = int(border.end.x)
	limit_bottom = int(border.end.y)


func _physics_process(delta: float) -> void:
	if player == null:
		return

	var to_player := player.global_position - global_position

	if to_player.length() <= deadzone_radius:
		return

	var direction := to_player.normalized()
	var target_position := player.global_position - direction * deadzone_radius

	var weight := 1.0 - exp(-follow_sharpness * delta)
	global_position = global_position.lerp(target_position, weight)
