extends Node

@onready var tutorial_scene: CanvasLayer = $TutorialScene
@onready var objectives_scene: CanvasLayer = $ObjectivesScene
@onready var trash_meter_scene: CanvasLayer = $TrashMeterScene

var ui_counter = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_ui"):
		ui_counter += 1
		if ui_counter == 4:
			ui_counter = 0
	match ui_counter:
		0:
			tutorial_scene.show()
		1:
			tutorial_scene.hide()
			trash_meter_scene.show()
			objectives_scene.show()
		2:
			objectives_scene.hide()
		3:
			trash_meter_scene.hide()

func _ready() -> void:
	Globals.dialog_end.connect(cutscenes)
	Globals.max_garbage = Globals.get_garbage_count()
	
	# Explicitly set drawing to 0 for the first conversation
	Globals.drawing = 0 
	
	Globals.npc_name = "???"
	Globals.npc_speech = ["Happy 7th Birthday, [color=#98776b]Van Gold[/color]!",
							"Will you hold a party in your place?"]
	Globals.player_option_1 = []
	Globals.player_option_2 = []
	Globals.talk()


func cutscenes():
	if Globals.drawing == 0:
		Globals.npc_name = "Van Gold"
		Globals.npc_speech = ["[wave]Thank you guys. I appreciate it a lot. But I don't think w—[/wave]"]
		Globals.player_option_1 = []
		Globals.player_option_2 = []

		Globals.drawing = 1 
		Globals.talk()
		return 

	elif Globals.drawing == 1:
		Globals.npc_name = "???"
		Globals.npc_speech = ["Hey everyone, it's [color=#98776b]Van Gold's Birthday.",
								"OMG, the [color=#98776b]cutest fish[/color] in the school, Van Gold?",
								"[b]YES! IT'S THAT VAN GOLD'S BIRTHDAY.[/b]",
								"I heard his [color=#98776b]brother[/color] is pretty handsome.",
								"Van Gold, would you invite us to your place?"]
		Globals.player_option_1 = []
		Globals.player_option_2 = []

		Globals.drawing = 2
		Globals.talk()
		return 

	elif Globals.drawing == 2:
		Globals.npc_name = "Van Gold"
		Globals.npc_speech = ["[wave]I don't think so guys. Our town's quite of a mess right now.[/wave]"]
		Globals.player_option_1 = []
		Globals.player_option_2 = []

		Globals.drawing = 3
		Globals.talk()
		return 

	elif Globals.drawing == 3:
		Globals.npc_name = "???"
		Globals.npc_speech = ["That's unfortunate.",
								"We really want to hang out with you, Van Gold.",
								"Yo, isn't that [color=#98776b]Van Gold's crush?[/color]",
								"She's asking him to invite us to his place.",
								"But, he said his town's a mess.",
								"No way, Van Gold would invite us now, would he?"]
		Globals.player_option_1 = []
		Globals.player_option_2 = []

		Globals.drawing = 4
		Globals.talk()
		return 

	elif Globals.drawing == 4:
		Globals.npc_name = "Van Gold"
		Globals.npc_speech = ["[wave]Oh sure thing. hahaha. I'll invite everyone to our place.[/wave]",
								"[wave]Hold on, guys. I just got a call. hahaha[/wave]"]
		Globals.player_option_1 = [] # Options aren't needed here, they are used in the NEXT dialog
		Globals.player_option_2 = []

		Globals.drawing = 5
		Globals.talk()
		return 

	elif Globals.drawing == 5:
		Globals.npc_name = "Van Gold"
		Globals.npc_speech = ["Brother, brother, helpppp.",
								"I know you've been busy in your work-from-home lately.",
								"But this is an emergency.",
								"You know today's a special day, right?",
								"XXXXX",
								"Nooo, did you really forgot about it?",
								"[b]It's my BIRTHDAY.[/b]",
								"XXXXX",
								"Look, there's no time to explain.",
								"My friends are coming to town tonight.",
								"XXXXX",
								"Knowing you, you still probably don't see the problem.",
								"[b]But the town is full of [rainbow]stars[/rainbow][/b]!!!",
								"Please stop everything you're doing. Don't prepare any foods, surprises, or whatsoever.",
								"Focus solely on cleaning the town as soon as possible. You may not even make it.",
								"XXXXX",
								"Now go step outside now to see what we're dealing with.",
								"Please brother, my friends can't see me living in such a dirty town.",
								"Oh barnacles, they're coming. Good b—",
								"XXXXX"]
		Globals.player_option_1 = ["Of course, the dark bear plushie is on sale today.", "Oh yea, I remember that.", "Inviting them over isn't that bad.", "(I'll prepare a surprise party for him LOL)", "Alright, time to start cleaning!"]
		Globals.player_option_2 = ["It's the release date of Grand Tide Auto 7.", "Oh, Happy birthday then little bro.", "Oh, I see the problem now (I don't)", "Don't underestimate your big brother.", "Time to feel the warmth of the sun again."]

		Globals.drawing = 6
		Globals.talk()
		return 

	elif Globals.drawing == 6:
		# The final dialog just ended. Now trigger the cutscene.
		Globals.drawing = 7 # Advance state so this doesn't loop infinitely
		
		# Wait one frame so all nodes and cameras are fully in the tree.
		await get_tree().process_frame

		# Start your cutscene chain (use the exact names from your Cutscenes array).
		Globals.play_cutscene_chain(["Opening1"])
		return
