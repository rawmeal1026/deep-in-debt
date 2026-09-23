extends CharacterBody2D

var SPEED = 250.0

@onready var audio_manager: Node = $AudioManager

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var mon_whale: Node2D = $"../Mon Whale"
@onready var mikoi_angelo: Node2D = $"../Mikoi Angelo"
@onready var carpa_vaggio: Node2D = $"../Carpa Vaggio"
@onready var leon_octo: Node2D = $"../Leon Octo"
@onready var picass_shark: Node2D = $"../Picass Shark"

var npc_list

var facing_direction := 1.0

var _previous_nearest_npc = null

func _ready() -> void:
	npc_list = [mon_whale, mikoi_angelo, carpa_vaggio, leon_octo, picass_shark]
	#audio_manager.play_or_update_loop("bgm")

func _process(_delta: float) -> void: #audio
	# --- Latch game_end the moment all 3 objectives are complete ---
	if not Globals.game_end:
		if Globals.objective_1 and Globals.objective_2 and Globals.objective_3:
			Globals.game_end = true
	
	var raw_npc = get_nearest_npc()
	
	match raw_npc:
		null:
			audio_manager.play_or_update_loop("bgm", 0)
			if Globals.drawing == 7:
				audio_manager.play_or_update_loop("bgm", 0)
				if _previous_nearest_npc != raw_npc:
					_previous_nearest_npc = raw_npc
					if not Globals.game_end:
						Globals.npc_out.emit()
		"Tuna Tello":
			if Globals.game_end:
				Globals.npc_name = "Press SPACE"
			else:
				Globals.npc_name = "Tuna Tello"
			audio_manager.play_or_update_loop("bgm", 6)
			if _previous_nearest_npc != raw_npc:
				_previous_nearest_npc = raw_npc
				if not Globals.game_end:
					Globals.npc_in.emit()
		"Van Gold":
			if Globals.game_end:
				Globals.npc_name = "Press SPACE"
			else:
				Globals.npc_name = "Van Gold"
			audio_manager.play_or_update_loop("bgm", 7)
			if _previous_nearest_npc != raw_npc:
				_previous_nearest_npc = raw_npc
				if not Globals.game_end:
					Globals.npc_in.emit()
		"Leon Octo":
			if Globals.game_end:
				Globals.npc_name = "Press SPACE"
			else:
				Globals.npc_name = "Leon Octo"
			audio_manager.play_or_update_loop("bgm", 2)
			if _previous_nearest_npc != raw_npc:
				_previous_nearest_npc = raw_npc
				if not Globals.game_end:
					Globals.npc_in.emit()
		"Picass Shark":
			if Globals.game_end:
				Globals.npc_name = "Press SPACE"
			else:
				Globals.npc_name = "Picass Shark"
			audio_manager.play_or_update_loop("bgm", 5)
			if _previous_nearest_npc != raw_npc:
				_previous_nearest_npc = raw_npc
				if not Globals.game_end:
					Globals.npc_in.emit()
		"Carpa Vaggio":
			if Globals.game_end:
				Globals.npc_name = "Press SPACE"
			else:
				Globals.npc_name = "Carpa Vaggio"
			audio_manager.play_or_update_loop("bgm", 1)
			if _previous_nearest_npc != raw_npc:
				_previous_nearest_npc = raw_npc
				if not Globals.game_end:
					Globals.npc_in.emit()
		"Mikoi Angelo":
			if Globals.game_end:
				Globals.npc_name = "Press SPACE"
			else:
				Globals.npc_name = "Mikoi Angelo"
			audio_manager.play_or_update_loop("bgm", 3)
			if _previous_nearest_npc != raw_npc:
				_previous_nearest_npc = raw_npc
				if not Globals.game_end:
					Globals.npc_in.emit()
		"Mon Whale":
			if Globals.game_end:
				Globals.npc_name = "Press SPACE"
			else:
				Globals.npc_name = "Mon Whale"
			audio_manager.play_or_update_loop("bgm", 4)
			if _previous_nearest_npc != raw_npc:
				_previous_nearest_npc = raw_npc
				if not Globals.game_end:
					Globals.npc_in.emit()


func _physics_process(delta: float) -> void:
	Globals.player_garbage_carry_count = get_collected_count()
	if Globals.player_garbage_carry_count < (Globals.bag_slow_interval * 2):
		SPEED = 250
	elif Globals.player_garbage_carry_count < (Globals.bag_slow_interval * 3):
		if Globals.roller_blades:
			SPEED = 250
		else:
			SPEED = 200
	else:
		if Globals.roller_blades:
			SPEED = 250
		else:
			SPEED = 100
	
	if Globals.anti_drag_boots:
		SPEED += 50
	
	if not Globals.in_cutscene:
		velocity = velocity.move_toward(Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED, 2000 * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 1000 * delta)
	update_animation(velocity)
	move_and_slide()
	var border := Globals.world_border
	var m := Globals.player_border_margin
	global_position = global_position.clamp(
		border.position + Vector2(m, m),
		border.end - Vector2(m, m)
	)

# ------------------------------------------------------------------
# Bag pickup / drop
# ------------------------------------------------------------------

## The position garbage should fly to (same spot the bag sits at).
func get_carry_target_position() -> Vector2:
	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_carry_target_position"):
		var target: Vector2 = Globals.carried_bag.call("get_carry_target_position")
		return target

	return global_position

# ------------------------------------------------------------------
# Functions that state what material was collected
# ------------------------------------------------------------------

func get_collected_materials() -> Array[String]:
	var result: Array[String] = []

	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_collected_materials"):
		result = Globals.carried_bag.call("get_collected_materials")

	return result

func get_last_collected_material() -> String:
	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_last_collected_material"):
		return str(Globals.carried_bag.call("get_last_collected_material"))

	return ""

func state_collected_materials() -> String:
	if not is_instance_valid(Globals.carried_bag):
		return "You are not holding a bag."

	if Globals.carried_bag.has_method("state_collected_materials"):
		return str(Globals.carried_bag.call("state_collected_materials"))

	return ""

func update_animation(movement: Vector2) -> void:
	if movement == Vector2.ZERO:
		if animated_sprite_2d.animation != "Idle":
			animated_sprite_2d.play("Idle")
	else:
		if animated_sprite_2d.animation != "Walk":
			animated_sprite_2d.play("Walk")

	if movement.x > 0.0:
		animated_sprite_2d.flip_h = false
		facing_direction = 1.0

	elif movement.x < 0.0:
		animated_sprite_2d.flip_h = true
		facing_direction = -1.0

func get_facing_direction() -> float:
	return facing_direction

var inside_npc = false

func get_nearest_npc():
	var npc_dist_dict := {}
	for npc in npc_list:
		npc_dist_dict.set(npc.name, self.global_position.distance_to(npc.global_position))
	var val_list = npc_dist_dict.values()
	if val_list.min() <= 80 and self.velocity.length() == 0:
		inside_npc = true
		return npc_dist_dict.find_key(val_list.min())
	if inside_npc and val_list.min() <= 80:
		return npc_dist_dict.find_key(val_list.min())
	inside_npc = false
	return null

func _on_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "Walk" and $AnimatedSprite2D.frame == 0 or $AnimatedSprite2D.frame == 3:
		audio_manager.play_sfx_oneshot("player_footstep")

func get_collected_count() -> int:
	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_collected_count"):
		return int(Globals.carried_bag.call("get_collected_count"))

	return 0
