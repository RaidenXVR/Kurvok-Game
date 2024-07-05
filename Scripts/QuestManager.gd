extends Node

# class_name QuestManager

var available_quests:Array[Quest]
var ongoing_quests:Array[Quest]
var completed_quests:Array[Quest]


func set_available_quests(quest_title:String):
	var path = "res://Saves/%s/%s.tres" % [GameData.current_save_file,quest_title]
	var quest = load(path) as Quest
	
	if quest and quest.state == Quest.Quest_State.UNSTARTED:

		if not (quest in available_quests+ongoing_quests+completed_quests):
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
	

func set_ongoing_quests(quest_title:String):
	var path = "res://Saves/%s/%s.tres" % [GameData.current_save_file,quest_title]
	var quest = ResourceLoader.load(path) as Quest
	if quest != null and quest not in ongoing_quests+completed_quests and quest in available_quests:
		available_quests.erase(quest)
		quest.state = Quest.Quest_State.IN_PROGRESS
		ResourceSaver.save(quest,path)
		ongoing_quests.append(quest)
	
func load_ongoing_quests():
	return ongoing_quests

func set_complete_quests(quest_title:String):
	var path = "res://Saves/%s/%s.tres" % [GameData.current_save_file,quest_title]
	var quest = ResourceLoader.load(path) as Quest
	if quest != null and quest in ongoing_quests:
		quest.state = Quest.Quest_State.COMPLETED
		ResourceSaver.save(quest,path)
		ongoing_quests.erase(quest)
		var quest_rewards = quest.rewards
		var inv = get_tree().root.get_node("World").get_node("CanvasLayer").get_node("Inventory")
		for item_id in quest_rewards.keys():
			if item_id == "money":
				GameData.add_money(quest_rewards[item_id])
			else:
				var invItem = InventoryItems.new()
				invItem.init(item_id, quest_rewards[item_id])
				inv.inventory.insert(invItem)
		completed_quests.append(quest)


func check_where_quest(quest_title):
	var found_quest_a = available_quests.filter(func(q):return q.quest_name == quest_title)
	if found_quest_a.size()!=0:
		return 0
	var found_quest_o = ongoing_quests.filter(func(q):return q.quest_name == quest_title)
	var found_quest_c = completed_quests.filter(func(q):return q.quest_name == quest_title)
	if found_quest_o.size()!=0 :
		return 1
	elif found_quest_c.size()!=0:
		return 2

func check_quest(quest_title):
	var found_quest = ongoing_quests.filter(func(q):return q.quest_name == quest_title)
	if found_quest.size()!=0:
		var quest = found_quest[0] as Quest
		for key in quest.target.keys():
			if !quest.current_target_amount[key] >= quest.target[key]:
				return false
		return true
		

func check_target(target_id:String, amount:int):
	var found_quests
	if target_id.is_valid_int():
		found_quests = ongoing_quests.filter(func(q):return _check_target(q, Quest.Quest_Types.GATHER))
		if found_quests.size()!=0:
			var second_found_quests = found_quests.filter(func(q:Quest):return _check_target(q,target_id))
			if second_found_quests.size()!=0:
				for quest:Quest in second_found_quests:
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
