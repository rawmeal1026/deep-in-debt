extends Area2D

func collect_all_in_range() -> void:
	for area in get_overlapping_areas():
		_on_area_entered(area)

func collect_garbage(garbage: Node2D) -> void:
	var material_name := ""
	
	if get_collected_count() < (Globals.bag_slow_interval * 3):
		if garbage.has_method("get_material_name"):
			material_name = str(garbage.call("get_material_name"))

		if garbage.has_method("collect"):
			garbage.call("collect", self)

		if material_name != "":
			# Store the material inside the bag the player is holding.
			if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("add_collected_material"):
				Globals.carried_bag.call("add_collected_material", material_name)

	else:
		pass

func get_garbage_from_area(area: Area2D) -> Node2D:
	if area.is_in_group("garbage"):
		return area

	var parent := area.get_parent() as Node2D

	if parent != null and parent.is_in_group("garbage"):
		return parent

	return null

func _on_area_entered(area: Area2D) -> void:
	# Only collect while holding a bag.
	if not is_instance_valid(Globals.carried_bag):
		return

	var garbage := get_garbage_from_area(area)

	if garbage == null:
		return

	if garbage.has_method("is_collectable"):
		if not garbage.call("is_collectable"):
			return

	collect_garbage(garbage)

func get_collected_count() -> int:
	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_collected_count"):
		return int(Globals.carried_bag.call("get_collected_count"))

	return 0

func _on_interaction_area_bag_picked_up() -> void:
	collect_all_in_range()
