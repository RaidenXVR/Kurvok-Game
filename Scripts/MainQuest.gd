extends Resource

class_name MainQuest

@export var main_quest_name: String
@export var on_going_quests: Array[Quest]
@export var completed_quests: Array[Quest]

@export var next_main_quest: MainQuest
@export var previous_main_quest: MainQuest
@export var requirements: Array[Dictionary]

func remove_quest():
	if on_going_quests:
		completed_quests.append(on_going_quests[0])
		on_going_quests.remove_at(0)

func check_requirements():
	if not previous_main_quest in QuestManager.completed_main_quest:
		return false
	for req in requirements:
		if "quest" in req.keys():
			var q_name = completed_quests.filter(func(q:Quest): return q.quest_name == req["quest"])
			if not q_name:
				return false
		elif "cutscene" in req.keys():
			if not req["cutscene"] in CutsceneManager.cutscenes_completed:
				return false
	
	return true

func check_target(target_id:String, amount:int):
	var found_quests
	if not target_id.is_valid_int():
		found_quests = on_going_quests.filter(func(q):return q.type == Quest.Quest_Types.KILL and target_id in q.target.keys())
		if found_quests.size()!=0:
			for quest:Quest in found_quests:
				quest.current_target_amount[target_id] += amount
				if quest.current_target_amount[target_id] >= quest.target[target_id] and quest.giver == "":

					completed_quests.append(quest)
					on_going_quests.erase(quest)

		else:
			found_quests = on_going_quests.filter(func(q):return _check_target(q, Quest.Quest_Types.TALK))
			if found_quests.size()!=0:
				var second_found_quests = found_quests.filter(func(q:Quest):return _check_target(q,target_id))
				if second_found_quests.size()!=0:
					for quest:Quest in second_found_quests:
						quest.current_target_amount[target_id] += amount
						var target_meet = true
						for q in quest.current_target_amount.keys():
							if quest.current_target_amount[q] < quest.target[q]:
								target_meet = false
								break
						if target_meet:
							completed_quests.append(quest)
							on_going_quests.erase(quest)
					check_empty()
					return 'found'
	
	check_empty()

func _check_target(q:Quest,state_or_key:Variant):

	if state_or_key is Quest.Quest_Types:
		return q.type == state_or_key
	if state_or_key is String:
		return state_or_key in q.target.keys()

func check_quest(npc_quest: Quest):
	var quest_title = npc_quest.quest_name
	var found_quest = on_going_quests.filter(func(q):return q.quest_name == quest_title)
	if found_quest.size()!=0:
		var quest = found_quest[0] as Quest
		if quest.type == Quest.Quest_Types.GATHER:
			for key in quest.target.keys():
				if GameData.player_inventory.get_amount_by_id(key) < quest.target[key]:
					return false
			return true
		for key in quest.target.keys():
			if !quest.current_target_amount[key] >= quest.target[key]:
				return false
		return true

func get_quest_by_giver(giver_name:String):
	var quests = on_going_quests.filter(func(q:Quest): return q.giver == giver_name)
	return quests

func check_empty():
	if len(on_going_quests) == 0:
		QuestManager.set_main_quest()

func check_quest_in_complete(quest_name: String):
	for c in completed_quests:
		if c.quest_name == quest_name:
			return true
	
	return false

func check_already_talking(npc_name: String):
	var found_quests = on_going_quests.filter(func(q):return _check_target(q, Quest.Quest_Types.TALK))
	if found_quests.size()!=0:
		var second_found_quests = found_quests.filter(func(q:Quest):return _check_target(q,npc_name))
		if second_found_quests:
			var is_already_talking = second_found_quests[0].current_target_amount[npc_name] >= second_found_quests[0].target[npc_name]
			return is_already_talking
	
	return 0

func check_talk_in_ongoing(npc_name):
	var found_quests = on_going_quests.filter(func(q):return _check_target(q, Quest.Quest_Types.TALK))
	if found_quests.size()!=0:
		var second_found_quests = found_quests.filter(func(q:Quest):return _check_target(q,npc_name))
		if len(second_found_quests) != 0:
			return true
	return false
	
func check_go_to_quest(map_name):
	for on in on_going_quests:
		if map_name in on.target.keys():
			completed_quests.append(on)
			on_going_quests.erase(on)
			if on.Cutscene_to_play:
				CutsceneManager.do_cutscene(on.Cutscene_to_play)
				
			
