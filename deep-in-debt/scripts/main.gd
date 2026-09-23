extends Node

@onready var tutorial_scene: CanvasLayer = $TutorialScene
@onready var objectives_scene: CanvasLayer = $ObjectivesScene
@onready var trash_meter_scene: CanvasLayer = $TrashMeterScene
@onready var audio_manager: Node = $AudioManager

var ui_counter = 0
var epilogue_started := false

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

	if event.is_action_pressed("end_game"):
		if not epilogue_started and Globals.objective_1 and Globals.objective_2 and Globals.objective_3:
			epilogue_started = true
			Globals.drawing = 8
			start_epilogue()
	
	if event.is_action_pressed("quit"):
		get_tree().quit()

func _ready() -> void:
<<<<<<< Updated upstream
	# ... any other setup code you already had ...
	Globals.max_garbage = Globals.get_garbage_count()
	
	# Wait one frame so all nodes and cameras are fully in the tree.
	await get_tree().process_frame

	# Start your cutscene chain (use the exact names from your Cutscenes array).
	Globals.play_cutscene_chain(["Opening1"])
=======
	if not Globals.dialog_end.is_connected(cutscenes):
		Globals.dialog_end.connect(cutscenes)
	Globals.max_garbage = Globals.get_garbage_count()
	Globals.current_garbage = Globals.max_garbage
	Globals.in_cutscene = false
	Globals.drawing = 7

'''
	Globals.npc_name = "???"
	Globals.npc_speech = ["Happy 7th Birthday, [color=#98776b]Van Gold[/color]!",
							"Will you hold a party in your place?"]
	Globals.player_option_1 = []
	Globals.player_option_2 = []
	Globals.talk()
'''
func start_epilogue() -> void:
	Globals.npc_name = "Surstromming"
	Globals.npc_speech = ["And with that, [color=#98776b]Van Gold[/color] got to experience the best birthday ever.",
							"[color=#98776b]Mikoi[/color] was the DJ, and his tracks were a hit to the kids.",
							"[color=#98776b]Carpa[/color] prepared cookies for all of Van's friends.",
							"[color=#98776b]Picass[/color] hosted a raffle for everyone.",
							"[color=#98776b]Leon[/color] pitched his new invention of an underwater ice cream machine (that actually works).",
							"And [color=#98776b]Mon[/color] sang at the end, which almost lulled everyone to sleep.",
							"Later, when the cake was gone and the guests went home, two brothers sat on a clean pier saying nothing at all.",
							"The town was full of stars that morning, if you knew where to look. It's full of them again tonight — [color=#98776b]the real ones[/color]. The ones that were always up there, waiting for someone to clear the view.",
							"The last '[color=#98776b]star[/color]' had been picked up, bagged, and hauled away. Which, honestly, was always the only way this story could end.",
							"Great artists are remembered for what they leave behind. But this family will be remembered for what they picked up.",
							"Thank you, Tuna Tello. The real stars get to shine again.",
							"See you next tide."]
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
								"[b]YES! IT'S THAT VAN GOLD'S BIRTHDAY![/b]",
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
								"Yo, isn't that [color=#98776b]Van Gold's crush[/color]?",
								"She's asking him to invite us to his place.",
								"But, he said his town's a mess.",
								"No way Van Gold would invite us now, would he?"]
		Globals.player_option_1 = []
		Globals.player_option_2 = []
		Globals.drawing = 4
		Globals.talk()
		return 

	elif Globals.drawing == 4:
		Globals.npc_name = "Van Gold"
		Globals.npc_speech = ["[wave]Oh sure thing. hahaha. I'll invite everyone to our place.[/wave]",
								"[wave]Hold on, guys. I just got a call. hahaha[/wave]"]
		Globals.player_option_1 = []
		Globals.player_option_2 = []
		Globals.drawing = 5
		Globals.talk()
		return 

	elif Globals.drawing == 5:
		Globals.npc_name = "Van Gold"
		Globals.npc_speech = ["Brother, brother, helpppp.",
								"You've been busy in your work-from-home lately.",
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
								"[b]But the town is full of [rainbow]stars[/rainbow]!!![/b]",
								"Please stop everything you're doing. Don't prepare any foods, surprises, or whatsoever.",
								"Focus solely on cleaning the town as soon as possible. You may not even make it.",
								"XXXXX",
								"Now go step outside to see what we're dealing with.",
								"Please brother, my friends can't see me living in such a dirty town.",
								"Oh barnacles, they're coming. Good b—",
								"XXXXX"]
		Globals.player_option_1 = ["Of course, the dark bear plushie is on sale today.", "Oh yea, I remember that.", "Inviting them over isn't that bad.", "(That makes me more wanting to prepare a surprise party.)", "Alright, time to start cleaning!"]
		Globals.player_option_2 = ["It's the release date of Grand Tide Auto 7.", "Oh, Happy birthday then little bro.", "Oh, I see the problem now. (I don't)", "Don't underestimate your big brother.", "Time to feel the warmth of the sun again."]
		Globals.drawing = 6
		Globals.talk()
		return 

	elif Globals.drawing == 6:
		Globals.drawing = 7
		await get_tree().process_frame
		Globals.play_cutscene_chain(["Opening1"])
		return
	
	# NOTE: no drawing == 8 branch here anymore. The epilogue is started
	# once by start_epilogue(); keeping it here would replay it forever
	# because cutscenes() runs on every dialog_end.
>>>>>>> Stashed changes
