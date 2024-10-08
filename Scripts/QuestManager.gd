extends Node

# class_name QuestManager

var available_quests:Array[Quest]
var ongoing_quests:Array[Quest]
var completed_quests:Array[Quest]

var current_main_quest: MainQuest
var completed_main_quest: Array[MainQuest]

func set_available_quests(quest:Quest):
	var all_q = available_quests+ongoing_quests+completed_quests
	var is_already_quest = all_q.filter(func(q:Quest): return q.quest_name == quest.quest_name)

	if not is_already_quest:
		var requirements = quest.quest_requirement
		if requirements.size() != 0:
			var completed_q = []
			for r in requirements:
				var qst = completed_quests.filter(func(q:Quest): return q.quest_name == r)
				if qst.size()!=0:
					completed_q+=qst
			
			if completed_q.size() != requirements.size():
				return false
		available_quests.append(quest)
		return true
	return false


func load_available_quests(quest_title:String):
	var found_quest = available_quests.filter(func(q):return q.quest_name == quest_title)
	if found_quest.size() != 0:
		return found_quest[0]
	return null
	

func set_ongoing_quests(que:Quest):
	var quest = available_quests.filter(func(q:Quest): return q.quest_name == que.quest_name)[0]

	if quest != null and quest not in ongoing_quests+completed_quests and quest in available_quests:
		available_quests.erase(quest)
		quest.state = Quest.Quest_State.IN_PROGRESS
		ongoing_quests.append(quest)
	
func load_ongoing_quests():
	return ongoing_quests

func set_complete_quests(que:Quest):
	var quest = ongoing_quests.filter(func(q:Quest): return q.quest_name == que.quest_name)[0]

	if quest != null and quest in ongoing_quests:
		quest.state = Quest.Quest_State.COMPLETED
		ongoing_quests.erase(quest)
		var quest_rewards = quest.rewards
		var inv = get_tree().root.get_node("World").get_node("CanvasLayer").get_node("Menu")
		for item_id in quest_rewards.keys():
			if item_id == "money":
				GameData.add_money(quest_rewards[item_id])
			else:
				var invItem = InventoryItems.new(item_id, quest_rewards[item_id])
				inv.inventory.insert(invItem)
		completed_quests.append(quest)


func check_where_quest(quest_title:String):
	var found_quest_a = available_quests.filter(func(q):return q.quest_name == quest_title)
	if found_quest_a.size()!=0:
		return 0
	var found_quest_o = ongoing_quests.filter(func(q):return q.quest_name == quest_title)
	var found_quest_c = completed_quests.filter(func(q):return q.quest_name == quest_title)
	if found_quest_o.size()!=0 :
		return 1
	elif found_quest_c.size()!=0:
		return 2
	return 3

func check_quest(npc_quest: Quest):
	var quest_title = npc_quest.quest_name
	var found_quest = ongoing_quests.filter(func(q):return q.quest_name == quest_title)
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
		

func check_target(target_id:String, amount:int):
	# if current_main_quest:
	# 	current_main_quest.check_target(target_id, amount)
	var found_quests
	if target_id.is_valid_int():
		found_quests = ongoing_quests.filter(func(q:Quest):return q.type == Quest.Quest_Types.GATHER and target_id in q.target.keys())
		if found_quests.size()!=0:
			for quest:Quest in found_quests:
				quest.current_target_amount[target_id] += amount
	else:
		found_quests = ongoing_quests.filter(func(q):return _check_target(q, Quest.Quest_Types.KILL))
		if found_quests.size()!=0:
			var second_found_quests = found_quests.filter(func(q:Quest):return _check_target(q,target_id))
			if second_found_quests.size()!=0:
				for quest:Quest in second_found_quests:
					quest.current_target_amount[target_id] += amount
		else:
			found_quests = ongoing_quests.filter(func(q):return _check_target(q, Quest.Quest_Types.TALK))
			if found_quests.size()!=0:
				var second_found_quests = found_quests.filter(func(q:Quest):return _check_target(q,target_id))
				if second_found_quests.size()!=0:
					for quest:Quest in second_found_quests:
						quest.current_target_amount[target_id] += amount

func _check_target(q:Quest,state_or_key:Variant):

	if state_or_key is Quest.Quest_Types:
		return q.type == state_or_key
	if state_or_key is String:
		return state_or_key in q.target.keys()

func check_talk(npc_name:String, add_mode: bool = false):
	var req_quest: Array[Quest] = ongoing_quests.filter(func(q:Quest): return npc_name in q.target.keys())

	if len(req_quest) != 0:
		if add_mode:
			for q in req_quest:
				q.current_target_amount[npc_name] +=1
			return 2
		else:
			return 1
	return 0

func get_talk_quest(npc_name:String) -> Array[Quest]:
	var req_quest: Array[Quest] = ongoing_quests.filter(func(q:Quest): return npc_name in q.target.keys())
	return req_quest


func set_main_quest(main_quest_to_set: MainQuest = null):
	if main_quest_to_set:
		current_main_quest = main_quest_to_set

	else: 
		if current_main_quest.next_main_quest and current_main_quest.next_main_quest.check_requirements():
			completed_main_quest.append(current_main_quest)
			current_main_quest = current_main_quest.next_main_quest
		else:
			completed_main_quest.append(current_main_quest)


