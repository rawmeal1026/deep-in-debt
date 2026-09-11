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
								"Van Gold's birthday is coming, isn't it? And you're planning a surprise party for him.",
								"XXXXX",
								"You'll want gift wrappers first. For that, bring me 10 paper boards.",
								"Remember, they must be polished by Mikoi Angelo before you bring them here. Only then will the wrappers come out in top condition.",
								"Once you have them polished, bring them to me. As payment for your initiative in cleaning my yard, I'll have your gift wrappers ready."]
		Globals.player_option_1 = ["How can you even know that?"]
		Globals.player_option_2 = ["Get out of my head, Leon."]
		Globals.talk()
		return
	
	if Globals.objective_2_counter == 0:
		if Globals.paper_count > 9:
			Globals.objective_2_counter += 1
			Globals.paper_count -= 10
			Globals.bag_slow_interval += 5
			Globals.npc_name = "Leon Octo"
			Globals.npc_speech = ["I'll create the wrappers as promised. But I can tell that's not enough for this surprise.",
									"You're thinking about party poppers next, aren't you? A proper welcome for Van Gold.",
									"XXXXX",
									"Go gather 20 hard plastics from bottles, and I'll get started.",
									"Oh, and before I forget. Here, take this.",
									"Hydrodynamic gloves.",
									"It'll let you carry more weight before slowing down.",
									"This shall also give all wearers more strength to fit more stars in their containers.",
									"You'll need it, with all this hauling back and forth.",
									"If you have any extra paper boards, I'll also buy it from you for two shells.",
									"I kinda need the materials for my project. Happy to have business with you."]
			Globals.player_option_1 = ["You read me like an open book."]
			Globals.player_option_2 = ["Please stop doing that, it's giving me creeps."]
			Globals.talk()
		return

	if Globals.objective_2_counter == 1:
		if Globals.hard_plastic_count > 19:
			Globals.objective_2_counter += 1
			Globals.hard_plastic_count -= 20
			Globals.anti_drag_boots = true
			Globals.npc_name = "Leon Octo"
			Globals.npc_speech = ["The wrappers are done. I'll start working on the poppers. They'll go off with quite a bang when he walks in.",
									"Now, what's a surprise party without balloons? I know that's what's on your mind.",
									"XXXXX",
									"Bring me 30 soft plastics, and the balloons will be ready in no time.",
									"Here, Anti-Drag Boots. A little gift for all your effort.",
									"They'll pick up your pace. You've still got a lot of ground left to cover.",
									"I'll buy your remaining hard plastics as well, now that you probably won't need it anymore."]
			Globals.player_option_1 = ["You always speak for me, Leon."]
			Globals.player_option_2 = ["Just tell me what to do, I'm not surprised anymore."]
			Globals.talk()
		return

	if Globals.objective_2_counter == 2:
		if Globals.soft_plastic_count > 29:
			Globals.objective_2_counter += 1
			Globals.soft_plastic_count -= 30
			Globals.roller_blades = true
			Globals.npc_name = "Leon Octo"
			Globals.npc_speech = ["I'll make the balloons right away. But there's one more thing weighing on your mind, isn't there?",
									"The gift itself. A robot toy, for Van Gold to unwrap.",
									"XXXXX",
									"Go collect 60 metal cans, and everything will be ready for his surprise.",
									"One more thing for you, Roller Blades.",
									"With this, even a full bag won't weigh you down. You're almost at the finish line.",
									"Make sure to bring your remaining soft plastics to me, just keep the materials on coming."]
			Globals.player_option_1 = ["Yep, that should be the last thing I'll request from you."]
			Globals.player_option_2 = ["If someone can read my intentions, doesn't that mean I don't have free will? Forget I said that."]
			Globals.talk()
		return

	if Globals.objective_2_counter == 3:
		if Globals.metal_count > 59:
			Globals.objective_2_counter += 1
			Globals.metal_count -= 60
			Globals.npc_name = "Leon Octo"
			Globals.npc_speech = ["There, I'll finish this robot, with gears and all, in no time.",
									"The wrappers, the poppers, the balloons, the gift — all set for Van Gold's big surprise.",
									"XXXXX",
									"Now, if you've got any polished materials left over, don't let them go to waste. I'll buy them off you as always, 2 shells apiece."]
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
