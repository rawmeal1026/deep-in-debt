extends Node

@export var quest_lines : Array[QuestData]
@export var after_quest_lines : Array[RandomSpeechData]

var quest_num = quest_lines.size()
var random_speech_num = after_quest_lines.size()
var quest_finished : int = 0

func start_quest():
	Globals.npc_speech = quest_lines[quest_finished].start_quest_actor_speech
	Globals.player_option_1 = quest_lines[quest_finished].start_quest_player_choice_1
	Globals.player_option_2 = quest_lines[quest_finished].start_quest_player_choice_2
	Globals.talk()

func finish_quest():
	Globals.npc_speech = quest_lines[quest_finished].finished_quest_actor_speech
	Globals.player_option_1 = quest_lines[quest_finished].finished_quest_player_choice_1
	Globals.player_option_2 = quest_lines[quest_finished].finished_quest_player_choice_2
	Globals.talk()
	quest_finished += 1

func remind_quest():
	Globals.npc_speech = quest_lines[quest_finished].unfinished_actor_speech
	Globals.talk()
	
func random_speech():
	var selected_speech = randi_range(0,random_speech_num - 1)
	
	Globals.npc_name = after_quest_lines[selected_speech].actor_name
	Globals.npc_speech = after_quest_lines[selected_speech].actor_speech
	Globals.talk()

func get_quest_num():
	return quest_num

func get_quest_finished():
	return quest_finished
