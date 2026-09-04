extends Node

var bag_slow_interval = 10
#First increase threshold = bag_slow_interval * 2
#Second increase threshold = bag_slow_interval * 3
#Max_bag_content = bag_slow_interval * 4

# Adjust this path to wherever your GarbageBag scene file actually is.
const GarbageBagScene := preload("res://scenes/entities/garbage_bag.tscn")

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

#if playing sfx with no parameter: Globals.play_fmod_sfx(path)
#if playing sfx with ONE parameter: Globals.play_fmod_sfx(path, parameter_name, parameter_value)


## Spawns a GarbageBag under Entities at the given position.
## Returns the spawned bag so you can configure it if needed.
func spawn_garbage_bag(at_position: Vector2) -> Node2D:
	var bag: Node2D = GarbageBagScene.instantiate()

	var entities := get_tree().current_scene.get_node_or_null("Entities")

	if entities == null:
		push_warning("spawn_garbage_bag(): Entities node not found.")
		bag.queue_free()
		return null

	# Parent it under Entities so it participates in Y Sort with everything else.
	entities.add_child(bag)

	# Set the position AFTER add_child, so global_position resolves correctly.
	bag.global_position = at_position

	return bag
