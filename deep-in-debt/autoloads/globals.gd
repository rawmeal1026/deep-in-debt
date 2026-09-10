extends Node


var bgm_instance
# FMOD GLOBALS
## path        = the FMOD event path, e.g. "event:/SFX/BagPickup"
## param_name  = name of the FMOD parameter to set ("" = no parameter)
## param_value = value for that parameter
func play_fmod_sfx(path: String, param_name := "", param_value := 0.0) -> void:
	if path.is_empty():
		push_warning(name + ": FMOD event path is empty.")
		return

	if param_name.is_empty():
		FmodServer.play_one_shot(path)
	else:
		FmodServer.play_one_shot_with_params(path, {param_name: float(param_value)})

# MANAGED: For SFX where you need to check if it's playing or finished
'''func play_fmod_sfx_managed(path: String, param_name := "", param_value := 0.0) -> FmodEvent:
	if path.is_empty():
		push_warning(name + ": FMOD event path is empty.")
		return null

	var instance: FmodEvent = FmodServer.create_event_instance(path)
	
	if not param_name.is_empty():
		instance.set_parameter_by_name(param_name, float(param_value))

	instance.start()
	return instance
#if playing sfx with no parameter: Globals.play_fmod_sfx(path)
#if playing sfx with ONE parameter: Globals.play_fmod_sfx(path, parameter_name, parameter_value)
'''

# BAG SLOW EFFECT GLOBALS

var bag_slow_interval = 10
var player_garbage_carry_count: int
var is_player_carrying_a_bag: bool = false
var carried_bag: Node2D = null
#First increase threshold = bag_slow_interval * 2
#Second increase threshold = bag_slow_interval * 3


# GARBAGE_BAG_FROM_WHALE_GLOBALS

# Adjust this path to wherever your GarbageBag scene file actually is.
const GarbageBagScene := preload("res://scenes/entities/garbage_bag.tscn")

## Spawns a GarbageBag under Entities at the given position.
## Returns the spawned bag so you can configure it if needed.
func spawn_garbage_bag(at_position: Vector2) -> Node2D:
	var bag: Node2D = GarbageBagScene.instantiate()
	var entities := get_tree().current_scene.get_node_or_null("Entities")

	if entities == null:
		push_warning("spawn_garbage_bag(): Entities node not found.")
		bag.queue_free()
		return null

	# 1. Set the position BEFORE adding to the tree. 
	# This ensures it resolves to the correct global position once added.
	bag.global_position = at_position

	# 2. Defer adding the child to avoid the "flushing queries" error.
	# This tells Godot: "Wait until the physics engine is done with the 
	# current collision before adding this new physics body to the world."
	entities.call_deferred("add_child", bag)

	return bag


# DIALOG GLOBALS
signal initiate_talk

var in_cutscene = false

func talk():
	in_cutscene = true
	initiate_talk.emit()

# Dialog Manager
var npc_name: String
var npc_speech: Array
var player_option_1: Array
var player_option_2: Array


# SHELL CURRENCY
var shell_count = 0
var soft_plastic_count = 0
var hard_plastic_count = 0
var metal_count = 0
var paper_count = 0
