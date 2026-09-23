extends Area2D

signal bag_picked_up
var bags_in_range: Array[Node2D] = []
var npc_in_range: Array[Node2D] = []

@onready var tuna_tello: CharacterBody2D = $".."

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("talk"):
		if not Globals.in_cutscene:
			var entity := get_nearest_npc()

			if entity != null:
				if entity.has_method("talk"):
					entity.call("talk")
				return

	if event.is_action_pressed("interact"):
		if not Globals.in_cutscene:
			var npc := get_nearest_npc()
			if npc != null:
				if npc.has_method("action"):
					npc.call("action")
			handle_bag_interaction()

#Adds entity entered to either bags_in_range or npc_in_range
func _on_area_entered(area: Area2D) -> void:
	var entity := get_entity_from_area(area)

	if entity != null:
		if entity.is_in_group("bag") and not bags_in_range.has(entity):
			bags_in_range.append(entity)
		if entity.is_in_group("npc") and not npc_in_range.has(entity):
			npc_in_range.append(entity)

#Removes entity exited from either bags_in_range or npc_in_range
func _on_area_exited(area: Area2D) -> void:
	var entity := get_entity_from_area(area)

	if entity != null:
		if entity.is_in_group("bag") and bags_in_range.has(entity):
			bags_in_range.erase(entity)
		if entity.is_in_group("npc") and npc_in_range.has(entity):
			npc_in_range.erase(entity)

#Get parent node (the entity itself) of an area
func get_entity_from_area(area: Area2D) -> Node2D:
	return area.get_parent() as Node2D

#Get nearest npc in interaction area
func get_nearest_npc() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for entity in npc_in_range:
		if not is_instance_valid(entity):
			continue

		var distance := global_position.distance_squared_to(entity.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = entity

	return nearest

#Get nearest bag in interaction area
func get_nearest_bag() -> Node2D:
	var nearest: Node2D = null
	var best_distance := INF

	for entity in bags_in_range:
		if not is_instance_valid(entity):
			continue

		#Excludes Carried Bags
		if entity.has_method("is_carried"):
			if entity.call("is_carried"):
				continue

		#Excludes Carried Garbage
		if entity.has_method("can_be_picked_up"):
			if not entity.call("can_be_picked_up"):
				continue

		var distance := global_position.distance_squared_to(entity.global_position)

		if distance < best_distance:
			best_distance = distance
			nearest = entity

	return nearest

#Drop a Bag when Holding a Bag, Carry a Bag when not Holding a Bag
func handle_bag_interaction() -> void:
	if is_instance_valid(Globals.carried_bag):
		if Globals.carried_bag.has_method("drop"):
			Globals.carried_bag.call("drop")
		Globals.carried_bag = null
		Globals.is_player_carrying_a_bag = false
		return

	Globals.carried_bag = null

	var bag := get_nearest_bag()

	if bag != null and bag.has_method("pick_up"):
		bag.call("pick_up", tuna_tello)
		Globals.carried_bag = bag
		Globals.is_player_carrying_a_bag = true
		# Collect any garbage already standing inside the collection area.
		bag_picked_up.emit()
