extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var e_button: Sprite2D = $E_button

var intro = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("Idle")
	Globals.dialog_end.connect(end_intro)

func interact():
	if intro:
		intro = false
		Globals.npc_name = "Mikoi Angelo"
		Globals.npc_speech = ["YO. Another star hunter pulling up, that's crazy, that's actually kinda crazy.",
								"Six-seven stars fell outta the sky last night alone.",
								"Bro said 'let there be glitter' and dropped these LITTER. Hell nahh",
								"XXXXX",
								"I'm the one who polishes 'em out and sorts the pile. Plastic here, metal there, and whatever this cappoccino-assassino-lookin' thing is goes in its own bin 'cause I genuinely cannot classify it.",
								"Other than my GOAT, Mon Whale, nobody else down here sorts 'em right, they just let the stars rot in big piles.",
								"That's how the water gets murky and the sky starts dimming. Skibidi behavior, not gonna lie.",
								"I'm the star custodian, no cap. I polish stars, my treat, sigma generosity type beat.",
								"I bring it back full and sorted proper. Use em materials however you like.",
								"Oh, you tryna cop a party for your bro's birthday? Bestie. My neighbor is RIGHT THERE.",
								"Bring them materials to him tentacles. Trust me, he'll cook the best party of your bro's life. 67.",
								"XXXXX"]
								
		Globals.player_option_1 = ["Why are you talking like that?", "Never ever open your mouth in front of me again :)"]
		Globals.player_option_2 = ["6767676767", "Gotcha twin."]
		Globals.talk()
		return

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
		return

	# The worker's bag lives on the worker object, not in Globals.
	var bag: Node2D = worker.get("carried_bag")

	# Must be carrying a bag.
	if not is_instance_valid(bag):
		return

	# Must have garbage in the bag.
	var collected_count := 0

	if worker.has_method("get_collected_count"):
		collected_count = int(worker.call("get_collected_count"))
	elif bag.has_method("get_collected_count"):
		collected_count = int(bag.call("get_collected_count"))

	if collected_count <= 0:
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


func _on_mikoi_angelo_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		if intro:
			e_button.show()
		else:
			if not is_instance_valid(Globals.carried_bag):
				return

			# Must have garbage in the bag.
			if Globals.player_garbage_carry_count <= 0:
				return
			
			e_button.show()

func end_intro():
	if not is_instance_valid(Globals.carried_bag):
				return

	# Must have garbage in the bag.
	if Globals.player_garbage_carry_count <= 0:
		return

	e_button.hide()

func _on_mikoi_angelo_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.hide()
