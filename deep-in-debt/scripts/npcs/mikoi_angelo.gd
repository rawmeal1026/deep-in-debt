extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("Idle")

func interact():
	polish()

func get_collected_materials() -> Array[String]:
	var result: Array[String] = []

	if is_instance_valid(Globals.carried_bag) and Globals.carried_bag.has_method("get_collected_materials"):
		result = Globals.carried_bag.call("get_collected_materials")

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
