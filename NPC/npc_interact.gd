extends Area2D


var npc_name: String
var quest
var quest_from_other


func _ready():
	npc_name = get_parent().name


func talk():
	quest = get_parent().npc_quest[0]
	var inv_node = get_tree().root.get_node("World").get_node("CanvasLayer").get_node("Inventory")
	var file_diag = FileAccess.get_file_as_string("res://NPC/npc_dialogue.json")
	var quest_file = FileAccess.get_file_as_string("res://NPC/quests.json")
	var quests_json = JSON.parse_string(quest_file)
	var dialogs = JSON.parse_string(file_diag)
	var dialogue_node = get_tree().root.get_node("World").get_node("CanvasLayer").find_child("Dialogue")
	var dialogue = dialogs[npc_name]
	var dialog
	var objtv = quests_json[quest]["objective"]

	if GameData.check_is_quest_in_report(quest) and objtv["type"] == "gather":  
		dialog = dialogue["quest-dialog"]["post-quest"] # complete the gather quest
		inv_node.inventory.remove(objtv["target_name"], objtv["amount"])
		GameData.complete_quest_for_gather(quest, quests_json[quest])
		dialogue_node.starter(dialog)
		
	elif !GameData.check_is_quest_in_report(quest) and quest in GameData.active_quests.keys() and objtv["type"] == "gather":
		dialog = dialogue["quest-dialog"]["in-quest"]
		dialogue_node.starter(dialog) #quest is still active
	
	elif not quest in GameData.active_quests.keys() and not quest in GameData.completed_quests and !GameData.check_is_quest_in_report(quest):
		var temp_diag = dialogue["quest-dialog"]
		dialog = temp_diag["pre-quest"]
		dialogue_node.starter(dialog, quest,objtv["type"], objtv["target_name"], objtv["amount"] )
	elif quest in GameData.active_quests.keys():
		dialog = dialogue["quest-dialog"]["in-quest"]
		dialogue_node.starter(dialog)
	elif GameData.check_is_quest_in_report(quest):
		dialog = dialogue["quest-dialog"]["post-quest"]
		GameData.complete_quest_for_kill(quest)
		dialogue_node.starter(dialog)
		
	elif (quest in GameData.completed_quests or quest == null or quest =="") and (dialogue.has("non-quest-dialog")):
		dialog = dialogue["non-quest-dialog"]
		dialogue_node.starter(dialog)



