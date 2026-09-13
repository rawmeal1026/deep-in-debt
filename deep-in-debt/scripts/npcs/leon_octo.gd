extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var e_button: Sprite2D = $E_button

var intro = true

func _ready() -> void:
	animated_sprite_2d.play("Idle")

func interact():
	if Globals.objective_2_counter > 0:
		Globals.shell_count += Globals.paper_count * 2
		Globals.paper_count = 0
	if Globals.objective_2_counter > 1:
		Globals.shell_count += Globals.hard_plastic_count * 2
		Globals.hard_plastic_count = 0
	if Globals.objective_2_counter > 2:
		Globals.shell_count += Globals.soft_plastic_count * 2
		Globals.soft_plastic_count = 0
	if Globals.objective_2_counter > 3:
		Globals.shell_count += Globals.metal_count * 2
		Globals.metal_count = 0

	if intro:
		intro = false
		Globals.npc_name = "Leon Octo"
		Globals.npc_speech = ["Ah, Tuna Tello. No need to explain — I already know why you're here.",
								"Van Gold's birthday is coming, isn't it? And you're planning a [color=#98776b]surprise party[/color] for him.",
								"XXXXX",
								"You'll want [rainbow]gift wrappers[/rainbow] first. For that, bring me [color=#98776b]25 paper boards[/color].",
								"Remember, they must be [color=#98776b]polished by Mikoi Angelo[/color] before you bring them here. Only then will the wrappers come out in top condition.",
								"Once you have them polished, bring them to me. I'll have your [rainbow]gift wrappers[/rainbow] ready."]
		Globals.player_option_1 = ["How can you even know that?"]
		Globals.player_option_2 = ["Get out of my head, Leon."]
		Globals.talk()
		return
	
	if Globals.objective_2_counter == 0:
		if Globals.paper_count > 24:
			Globals.objective_2_counter += 1
			Globals.paper_count -= 25
			Globals.bag_slow_interval += 5
			Globals.npc_name = "Leon Octo"
			Globals.npc_speech = ["I'll create the wrappers as promised. But I can tell that's not enough for this surprise.",
									"You're thinking about [rainbow]party poppers[/rainbow] next, aren't you? A proper welcome for Van Gold.",
									"XXXXX",
									"Go gather [color=#98776b]80 hard plastics[/color] from bottles, and I'll get started.",
									"Oh, and before I forget. Here, take this.",
									"[b]Hydrodynamic gloves[/b]",
									"It'll let you [color=#98776b]carry more weight before slowing down[/color].",
									"This shall also give all wearers [color=#98776b]more strength to fit more stars in their containers[/color].",
									"You'll need it, with all this hauling back and forth.",
									"If you have any [color=#98776b]extra paper boards[/color], I'll also buy it from you for [color=#98776b]two shells[/color].",
									"I kinda need the materials for my project. Happy to have business with you."]
			Globals.player_option_1 = ["You read me like an open book."]
			Globals.player_option_2 = ["Please stop doing that, it's giving me creeps."]
			Globals.talk()
		return

	if Globals.objective_2_counter == 1:
		if Globals.hard_plastic_count > 79:
			Globals.objective_2_counter += 1
			Globals.hard_plastic_count -= 80
			Globals.anti_drag_boots = true
			Globals.npc_name = "Leon Octo"
			Globals.npc_speech = ["The wrappers are done. I'll start working on the poppers. They'll go off with quite a bang when he walks in.",
									"Now, what's a surprise party without [rainbow]balloons[/rainbow]? I know that's what's on your mind.",
									"XXXXX",
									"Bring me [color=#98776b]110 soft plastics[/color], and the balloons will be ready in no time.",
									"Here, take this as well. A little gift for all your effort.",
									"[b]Anti-Drag Boots[/b]",
									"They'll [color=#98776b]pick up your pace[/color]. You've still got a lot of ground left to cover.",
									"I'll buy your remaining [color=#98776b]hard plastics[/color] as well, now that you probably won't need it anymore."]
			Globals.player_option_1 = ["You always speak for me, Leon."]
			Globals.player_option_2 = ["Just tell me what to do, I'm not surprised anymore."]
			Globals.talk()
		return

	if Globals.objective_2_counter == 2:
		if Globals.soft_plastic_count > 109:
			Globals.objective_2_counter += 1
			Globals.soft_plastic_count -= 110
			Globals.roller_blades = true
			Globals.npc_name = "Leon Octo"
			Globals.npc_speech = ["You're faster than I've expected.",
									"I received the materials, but there's one more thing weighing on your mind, isn't there?",
									"The gift itself. A [rainbow]robot toy[/rainbow], for Van Gold to unwrap.",
									"XXXXX",
									"Go collect [color=#98776b]180 metal cans[/color], and everything will be ready for his surprise.",
									"One more thing for you",
									"[b]Roller Blades[/b]",
									"With this, even a [color=#98776b]full bag won't weigh you down[/color]. You're almost at the [color=#98776b]finish line[/color].",
									"Make sure to bring your remaining [color=#98776b]soft plastics[/color] to me, just keep the materials on coming."]
			Globals.player_option_1 = ["Yep, that should be the last thing I'll request from you."]
			Globals.player_option_2 = ["Sure thing, Octinator."]
			Globals.talk()
		return

	if Globals.objective_2_counter == 3:
		if Globals.metal_count > 179:
			Globals.objective_2_counter += 1
			Globals.metal_count -= 180
			Globals.npc_name = "Leon Octo"
			Globals.npc_speech = ["There, I'll finish this robot, with gears and all, in no time.",
									"The [rainbow]wrappers[/rainbow], the [rainbow]poppers[/rainbow], the [rainbow]balloons[/rainbow], the [rainbow]gift[/rainbow] — all set for Van Gold's big surprise.",
									"XXXXX",
									"Now, if you've got any polished materials left over, don't let them go to waste. I'll buy them off you as always, [color=#98776b]2 shells apiece[/color]."]
			Globals.player_option_1 = ["Thanks for everything."]
			Globals.player_option_2 = ["(He know I'm grateful anyway, so why trouble even saying it.)"]
			Globals.talk()
		return


func _on_leon_octo_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.show()


func _on_leon_octo_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_interaction"):
		e_button.hide()
