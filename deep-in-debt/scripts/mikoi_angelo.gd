extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("Idle")

## Called by the player when they press interact near this NPC.
func buy() -> void:
	# Must be carrying a bag.
	if not is_instance_valid(Globals.carried_bag):
		print("No bag to sell.")
		return

	# Must have garbage in the bag.
	if Globals.player_garbage_carry_count <= 0:
		print("The bag is empty.")
		return

	# Add one shell per garbage item.
	Globals.shell_count += Globals.player_garbage_carry_count

	print("Sold ", Globals.player_garbage_carry_count, " items for ", Globals.player_garbage_carry_count, " shells.")
	print("Total shells: ", Globals.shell_count)

	# Destroy the bag instance.
	Globals.carried_bag.queue_free()

	# Reset the player's carrying state.
	Globals.carried_bag = null
	Globals.is_player_carrying_a_bag = false
	Globals.player_garbage_carry_count = 0
