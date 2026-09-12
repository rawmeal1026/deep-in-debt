extends Node


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
const WasteHaulerScene := preload("res://scenes/npcs/waste_hauler.tscn")
const WasteCollectorScene := preload("res://scenes/npcs/waste_collector.tscn")

## Spawns a GarbageBag under Entities at the given position.
## Returns the spawned bag so you can configure it if needed.
func spawn_garbage_bag(at_position: Vector2) -> Node2D:
	var bag: Node2D = GarbageBagScene.instantiate()
	var entities := get_tree().current_scene.get_node_or_null("T-Sorted World/Entities")

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

func spawn_garbage_collector(at_position: Vector2) -> Node2D:
	var worker: Node2D = WasteCollectorScene.instantiate()
	var entities := get_tree().current_scene.get_node_or_null("T-Sorted World/Entities")

	if entities == null:
		push_warning("spawn_garbage_collector(): Entities node not found.")
		worker.queue_free()
		return null

	# 1. Set the position BEFORE adding to the tree. 
	# This ensures it resolves to the correct global position once added.
	worker.global_position = at_position

	# 2. Defer adding the child to avoid the "flushing queries" error.
	# This tells Godot: "Wait until the physics engine is done with the 
	# current collision before adding this new physics body to the world."
	entities.call_deferred("add_child", worker)

	return worker

func spawn_garbage_hauler(at_position: Vector2) -> Node2D:
	var worker: Node2D = WasteHaulerScene.instantiate()
	var entities := get_tree().current_scene.get_node_or_null("T-Sorted World/Entities")

	if entities == null:
		push_warning("spawn_garbage_hauler(): Entities node not found.")
		worker.queue_free()
		return null

	# 1. Set the position BEFORE adding to the tree. 
	# This ensures it resolves to the correct global position once added.
	worker.global_position = at_position

	# 2. Defer adding the child to avoid the "flushing queries" error.
	# This tells Godot: "Wait until the physics engine is done with the 
	# current collision before adding this new physics body to the world."
	entities.call_deferred("add_child", worker)

	return worker

# DIALOG GLOBALS
signal initiate_talk

var in_cutscene = false

func talk():
	in_cutscene = true
	initiate_talk.emit()

# Dialog Manager
signal dialog_end

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

# WORLD BORDER
var world_border := Rect2(48.0, -328.0, 2928.0, 2400.0)
var player_border_margin := 8.0



var objective_1 = false
var objective_2 = false
var objective_3 = false
var objective_2_counter = 0
var anti_drag_boots = false
var roller_blades = false
var max_garbage = 0


func play_cutscene_chain(names: Array[String]) -> void:
	var manager := get_tree().get_first_node_in_group("cutscene_manager")

	if manager != null and manager.has_method("play_cutscene_chain"):
		manager.call("play_cutscene_chain", names)

# GARBAGE COUNT GLOBALS

var garbage_group: String = "garbage"

## How many garbage nodes exist right now (collected or not).
func get_garbage_count() -> int:
	return get_tree().get_nodes_in_group(garbage_group).size()


## How many garbage pieces are still waiting to be collected.
func get_remaining_garbage_count() -> int:
	var count := 0

	for node in get_tree().get_nodes_in_group(garbage_group):
		var target := node as Node2D

		if target == null or not is_instance_valid(target):
			continue

		var garbage := target
		if not garbage.has_method("collect"):
			var parent := target.get_parent() as Node2D
			if parent != null and parent.has_method("collect"):
				garbage = parent

		if garbage.has_method("is_collected") and garbage.call("is_collected"):
			continue

		if garbage.has_method("is_collectable") and not garbage.call("is_collectable"):
			continue

		count += 1

	return count
