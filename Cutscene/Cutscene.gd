extends Resource

class_name Cutscene

@export var cutscene_name: String
@export var cutscene_quest_requirements:Array[Quest]
@export var cutscene_main_quest_requirements: MainQuest
@export var main_quest_to_set: MainQuest
@export var player_facing: Vector2
@export var cutscene_to_do: Array


func check_quest_requirements():
	if cutscene_quest_requirements:
		for requirement in cutscene_quest_requirements:
			if not (requirement in QuestManager.completed_quests):
				return false
	
	elif cutscene_main_quest_requirements:
		if not cutscene_main_quest_requirements in QuestManager.completed_main_quest:
			return false


	return true

func set_main_quest():
	if main_quest_to_set:
		QuestManager.set_main_quest(main_quest_to_set)
