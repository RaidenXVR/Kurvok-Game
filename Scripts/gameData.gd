extends Node


var chest_states = {}
var player_stats: Stats
var player_inventory:Inventory
var items_equiped:Array[int] = [] #0 helmet, 1 torso, 2 boots, 3 weap1, 4 weap2, 5 acc1, 6 acc2
var main_quest_state: String = "MQ Name"

var enemy_slain: Dictionary= {}
var money : int = 10
var current_skill_tree = SkillTree.Skill_Tree.WIND
var current_skill_equipped = 1

var current_save_file
var player_position
var current_map

signal money_change(money)


# func _ready():
# 	load_game(0)
# 	print(player_position)
	

func set_chest_state(chest_name, is_opened):
	chest_states[chest_name] = is_opened

func get_chest_state(chest_name):
	return chest_states.get(chest_name, false)




func enemy_slayed(enemy_name):
	if !enemy_slain.has(enemy_name):
		enemy_slain[enemy_name] = 0
	enemy_slain[enemy_name]+=1

func get_enemy_slain(enemy_name):
	if !enemy_slain.has(enemy_name):
		enemy_slain[enemy_name] = 0
	return enemy_slain[enemy_name] 


func add_money(money_to_add):
	money += money_to_add
	var moneyUI = get_tree().root.get_node("World").get_node("CanvasLayer").get_node("MoneyUI")
	if not money_change.is_connected(moneyUI.money_changed):
		money_change.connect(moneyUI.money_changed)
	emit_signal("money_change", money)

func decrease_money(how_much):
	money -= how_much
	var moneyUI = get_tree().root.get_node("World").get_node("CanvasLayer").get_node("MoneyUI")
	if not money_change.is_connected(moneyUI.money_changed):
		money_change.connect(moneyUI.money_changed)
	emit_signal("money_change", money)

func json_getter(json_file_name, path_without_res):
	var file = FileAccess.get_file_as_string("res://{path}/{file_name}.json".format({"path":path_without_res, "file_name": json_file_name}))
	return JSON.parse_string(file)


func save_game():
	var player_node = get_node("/root/World/Player")
	var map_node = get_node("/root/World/maps").get_child(0)

	var data = Data.new()
	data.save_data(player_node.global_position, map_node.name)
	ResourceSaver.save(data, "res://Saves/%s.tres" %[current_save_file])
	ResourceSaver.save(player_inventory, "res://Saves/%s/playerInventory.tres" % [current_save_file])



func load_game(save_file_int:int):
	var save_file
	current_save_file = "Save"+str(save_file_int)
	var dire  = DirAccess.open("res://")
	if dire.file_exists("res://Saves/%s.tres" % [current_save_file]):
		save_file = load("res://Saves/%s.tres" % [current_save_file]) as Data


	if save_file != null:
		chest_states = save_file.chest_states
		player_stats = save_file.player_stats
		player_inventory = save_file.player_inventory
		items_equiped = save_file.items_equiped
		main_quest_state = save_file.main_quest_state
		enemy_slain = save_file.enemy_slain
		money = save_file.money
		current_skill_tree = save_file.current_skill_tree
		current_skill_equipped = save_file.current_skill_equipped

		QuestManager.available_quests = save_file.available_quests
		QuestManager.ongoing_quests = save_file.ongoing_quests
		QuestManager.completed_quests = save_file.completed_quests

		player_position = save_file.player_position
		current_map = "res://map/%s.tscn" % save_file.map_name
	else:
		save_file = Data.new()
		ResourceSaver.save(save_file, "res://Saves/%s.tres" % [current_save_file])
		DirAccess.make_dir_absolute("res://Saves/%s"% [current_save_file])
		DirAccess.copy_absolute("res://player/playerInventory.tres", "res://Saves/%s/playerInventory.tres"% [current_save_file])
		player_inventory = load("res://Saves/%s/playerInventory.tres"% [current_save_file])
		var dir = DirAccess.open("res://Quests")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			dir.copy("res://Quests/"+file_name, "res://Saves/%s/"%[current_save_file]+file_name)
			file_name = dir.get_next()
		
		player_position = Vector2(100,544)