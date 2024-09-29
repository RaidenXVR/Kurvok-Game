extends Node

signal equip_skill_change

var chest_states = {}
var player_stats: Stats
var player_inventory:Inventory
#var items_equiped:Array = [] #0 helmet, 1 torso, 2 boots, 3 weap1, 4 weap2, 5 acc1, 6 acc2
var armor_equip1:InventoryItems
var armor_equip2: InventoryItems
var armor_equip3: InventoryItems
var weapon_equip: InventoryItems
var main_quest_state: String = "MQ Name"

var enemy_slain: Dictionary= {}
var money : int = 10

var current_skill_tree = SkillTree.Skill_Tree.WIND
var current_skill_equipped = 1
var skill_learned: Array[Skill]
var skill_available: Array[Skill]
var skill_slot_1: Skill
var skill_slot_2:Skill
var skill_slot_3: Skill
var skill_passive:Skill

var current_save_file
var player_position
var current_map
var is_game_over = false


signal money_change(money)

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


func update_stats(effects: Dictionary, time:float=0, is_unequip: bool= false):
	if time == 0:
		if not is_unequip:
			for effect in effects:
				match effect:
					"atk":
						player_stats.att += effects[effect]
					"def":
						player_stats.def += effects[effect]
					"max_mana":
						player_stats.max_mana += effects[effect]
		else:
			for effect in effects:
				match effect:
					"atk":
						player_stats.att -= effects[effect]
					"def":
						player_stats.def -= effects[effect]
					"max_mana":
						player_stats.max_mana -= effects[effect]
		
	else:
		var tm = Timer.new()
		
		for effect in effects:
			var buff_icon
			match effect:
				"atk":
					player_stats.att += effects[effect]
					if effects[effect] > 0:
						buff_icon = StatusIcon.new("atk_up", tm, time)
					else:
						buff_icon = StatusIcon.new("atk_down", tm, time)
						
				"def":
					player_stats.def += effects[effect]

					if effects[effect] > 0:
						buff_icon = StatusIcon.new("def_up", tm, time)
					else:
						buff_icon = StatusIcon.new("def_down", tm, time)
				"max_mana":
					player_stats.max_mana += effects[effect]
					buff_icon = StatusIcon.new("mana_up", tm, time)
					
			get_node("/root/World/CanvasLayer/StatusContainer").add_child(buff_icon)
		
		
		tm.one_shot = true
		tm.connect("timeout", func(): _on_buff_timer_timeout(effects, tm))
		get_node("/root/World/StatusTimers").add_child(tm)
		tm.start(time)
		print(NOTIFICATION_PAUSED)
		if NOTIFICATION_PAUSED:
			tm.paused = true

func _on_buff_timer_timeout(effects:Dictionary, timer:Timer):
	for effect in effects:
		match effect:
			"atk":
				player_stats.att -= effects[effect]
			"def":
				player_stats.def -= effects[effect]
			"max_mana":
				player_stats.max_mana -= effects[effect]
	
	timer.queue_free()


func save_game():
	var player_node = get_node("/root/World/Player")
	var map_node = get_node("/root/World/maps").get_child(0)

	var data = Data.new()
	data.save_data(player_node.global_position, map_node.name)
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("user://Saves"):
		dir.make_dir("Saves")
		
	ResourceSaver.save(data, "user://Saves/%s.tres" %[current_save_file])



func load_game(save_file_int:int):
	is_game_over = false
	var save_file: Data
	current_save_file = "Save"+str(save_file_int)
	var dire  = DirAccess.open("user://")
	if dire.file_exists("user://Saves/%s.tres" % [current_save_file]):
		save_file = load("user://Saves/%s.tres" % [current_save_file]) as Data


	if save_file == null:
		save_file = Data.new()
		save_file.weapon_equip = InventoryItems.new()
		save_file.weapon_equip.init("4", 1)
		save_file.armor_equip1 = InventoryItems.new()
		save_file.armor_equip1.init("3", 1)
		weapon_equip = save_file.weapon_equip
		armor_equip1 = save_file.armor_equip1
		save_file.player_inventory.insert(weapon_equip)
		save_file.player_inventory.insert(armor_equip1)
		save_file.player_inventory.use_item(0, "equipment")
		save_file.player_inventory.use_item(1,"equipment")
	
	chest_states = save_file.chest_states
	player_stats = save_file.player_stats
	player_inventory = save_file.player_inventory

	weapon_equip = save_file.weapon_equip
	armor_equip1 = save_file.armor_equip1
	armor_equip2 = save_file.armor_equip2
	armor_equip3 = save_file.armor_equip3
	player_inventory.updated.emit()
	main_quest_state = save_file.main_quest_state
	enemy_slain = save_file.enemy_slain
	money = save_file.money
	
	current_skill_tree = save_file.current_skill_tree
	current_skill_equipped = save_file.current_skill_equipped
	skill_learned = save_file.skill_learned
	skill_available = save_file.skill_available
	skill_slot_1 = save_file.skill_slot_1
	skill_slot_2 = save_file.skill_slot_2
	skill_slot_3 = save_file.skill_slot_3
	skill_passive = save_file.skill_passive

	QuestManager.available_quests = save_file.available_quests
	QuestManager.ongoing_quests = save_file.ongoing_quests
	QuestManager.completed_quests = save_file.completed_quests
	QuestManager.current_main_quest = save_file.current_main_quest
	QuestManager.completed_main_quest = save_file.completed_main_quest

	CutsceneManager.cutscenes_completed = save_file.cutscenes_completed

	player_position = save_file.player_position
	current_map = "res://map/%s.tscn" % save_file.map_name
	

func do_game_over():
	var cam_coor = get_viewport().get_camera_2d().get_screen_center_position()
	var player: Player = get_node("/root/World/Player")
	var col_rect:ColorRect = get_node("/root/World/CanvasLayer/GameOver/ColorRect")
	var sprite: Sprite2D = get_node("/root/World/CanvasLayer/GameOver/Sprite2D")
	var anim_player:AnimationPlayer = get_node("/root/World/CanvasLayer/GameOver/AnimationPlayer")
	var text:Label = get_node("/root/World/CanvasLayer/GameOver/GameOverText")
	var key_text: Label = get_node("/root/World/CanvasLayer/GameOver/KeyText")
	var viewport_size = get_viewport().get_visible_rect().size

	sprite.position  = player.get_global_transform_with_canvas().origin
	sprite.visible = true
	col_rect.custom_minimum_size = viewport_size
	player.set_process_input(false)
	player.set_physics_process(false)
	cam_coor.y += 50
	
	for child in get_node("/root/World/CanvasLayer").get_children():
		child.visible = false
		
	col_rect.get_parent().visible = true
	player.visible = false
	anim_player.play("fainted")
	await anim_player.animation_finished
	
	get_node("/root/World/maps").visible = false
	

	if player.get_global_transform_with_canvas().origin.distance_to(cam_coor) > 10:
		var tween = create_tween()
		tween.tween_property(col_rect,"color", Color(0,0,0,1), 2)
		tween.parallel().tween_property(sprite,"position", (viewport_size/2) - Vector2(20,-40), 2)
		tween.tween_callback(_do_game_over)
		await tween.finished
	
	text.visible = true
	var tween_text = create_tween()
	tween_text.bind_node(col_rect.get_parent())
	tween_text.tween_property(text, "position", Vector2(350, 70), 1)
	await tween_text.finished
	
	key_text.visible = true
	var tween_key = create_tween().bind_node(col_rect.get_parent()).set_loops()
	tween_key.tween_property(key_text, "modulate", Color.WHITE, 0)
	tween_key.tween_interval(1)
	tween_key.tween_property(key_text, "modulate", Color.TRANSPARENT, 0)
	tween_key.tween_interval(1)
	
	
func _do_game_over():
	is_game_over = true

func _input(event):
	if is_game_over and event is InputEventKey:
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
		is_game_over = false
		
