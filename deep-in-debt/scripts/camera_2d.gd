extends Camera2D

@export var player_path: NodePath
@export var deadzone_radius := 120.0
@export var follow_sharpness := 5.0

var player: CharacterBody2D


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	make_current()


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
