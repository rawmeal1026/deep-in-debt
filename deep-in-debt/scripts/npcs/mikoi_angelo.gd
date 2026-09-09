extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("Idle")

func interact():
	polish()

## Returns the materials inside the given bag.
## If no bag is passed, it falls back to the player's bag in Globals.
func get_collected_materials(bag: Node2D = null) -> Array[String]:
	var result: Array[String] = []

	var source: Node2D = bag

	if source == null:
		source = Globals.carried_bag

	if is_instance_valid(source) and source.has_method("get_collected_materials"):
		result = source.call("get_collected_materials")

	return result

## Called by the player when they press interact near this NPC.
func polish() -> void:
	# Must be carrying a bag.
	if not is_instance_valid(Globals.carried_bag):
		print("No bag to polish.")
		return

	# Must have garbage in the bag.
	if Globals.player_garbage_carry_count <= 0:
		print("The bag is empty.")
		return

	for i in get_collected_materials():
		match i:
			"PE Bags":
				Globals.soft_plastic_count += 1
			"PET Bottles":
				Globals.hard_plastic_count += 1
			"Cellulose Paperboards":
				Globals.paper_count += 1
			"Aluminum Cans":
				Globals.metal_count += 1
			_:
				print(i)
				
	if Globals.carried_bag.has_method("drop"):
			Globals.carried_bag.call("drop")
			
	Globals.carried_bag.queue_free()

	# Reset the player's carrying state.
	Globals.carried_bag = null
	Globals.is_player_carrying_a_bag = false
	Globals.player_garbage_carry_count = 0

## Called by a worker (waste hauler) when it delivers a full bag.
## The worker passes itself in, because worker traits live on the
## worker object itself, not in Globals.
func worker_interact(worker: Node2D) -> void:
	if not is_instance_valid(worker):
		print("No worker at the door.")
		return

	# The worker's bag lives on the worker object, not in Globals.
	var bag: Node2D = worker.get("carried_bag")

	# Must be carrying a bag.
	if not is_instance_valid(bag):
		print("The worker has no bag.")
		return

	# Must have garbage in the bag.
	var collected_count := 0

	if worker.has_method("get_collected_count"):
		collected_count = int(worker.call("get_collected_count"))
	elif bag.has_method("get_collected_count"):
		collected_count = int(bag.call("get_collected_count"))

	if collected_count <= 0:
		print("The worker's bag is empty.")
		return

	for i in get_collected_materials(bag):
		match i:
			"PE Bags":
				Globals.soft_plastic_count += 1
			"PET Bottles":
				Globals.hard_plastic_count += 1
			"Cellulose Paperboards":
				Globals.paper_count += 1
			"Aluminum Cans":
				Globals.metal_count += 1
			_:
				print(i)

	if bag.has_method("drop"):
		bag.call("drop")

	bag.queue_free()

	# Reset the worker's carrying state.
	if worker.has_method("clear_carried_bag"):
		worker.call("clear_carried_bag")
	else:
		worker.set("carried_bag", null)
		worker.set("is_carrying_bag", false)
