extends Control

class_name Dialogue

signal trigger_quest(quest_name, q_type, objtv, amn)
signal check_quest_completion
signal dialogue_finished

var lines:Array 
var line
# var actors:Array
var actorL
var actorR
var current_dialog_index:int
var current_text = ""
var type_speed = 0.05
var is_finished_talking: bool = true
var special_var: Dictionary = {}
var quest: Quest
var objective
var amount
var quest_type
var is_option: bool = false
var actors_gender: Dictionary
var audio_stream = AudioStream.new()

@onready var leftActor = $LeftPortrait
@onready var rightActor = $RightPortrait
@onready var dial_text = $Panel/Label
@onready var name_tag_panel = $NameLabel
@onready var name_tag = $NameLabel/Label
@onready var type_timer: Timer = $TypingTimer
@onready var options = $Options
@onready var audio_player: AudioStreamPlayer = AudioManager.audio_players["sfx"]
@onready var player_hpbar = get_tree().root.get_node("/root/World/CanvasLayer/PlayerHealthBar")
@onready var gold = get_tree().root.get_node("/root/World/CanvasLayer/MoneyUI")

var female_typing = preload("res://Audio/dia5.wav")
var male_typing = preload("res://Audio/dia6.wav")

func _ready():

	type_timer.connect("timeout",_on_typing_timeout)
	type_timer.wait_time = type_speed



func starter(dialog, name_npc:String, q:Quest = null, is_cutscene: bool = false, cutscene_actors:Array=[]):
	quest = q
	get_tree().paused = true
	visible = true
	is_finished_talking = false
	lines.clear()

	for canvas in get_node("/root/World/CanvasLayer").get_children():
		if canvas != self:
			canvas.visible = false


	for item in dialog:
		var dict_item = {"dialogue":item["dialogue"], "char":item["char"]}
		# actors.append(item["char"])

		if item.has("options") and len(item["options"])>0:
			dict_item["options"] = item["options"]
			if item["options"].has("special_var"):
				if !item["options"]["special_var"].is_empty():
					special_var = item["options"].get("special_var")
					item["options"].erase("special_var")
		lines.append(dict_item)
		

	current_dialog_index = 0
	line = lines[current_dialog_index]

	var file_diag = FileAccess.get_file_as_string("res://NPC/npc_dialogue.json")
	var dialogs = JSON.parse_string(file_diag)

	if not is_cutscene:
		if len(dialogs[name_npc]["actors"]) >= 2:
			actorL = dialogs[name_npc]["actors"][0].keys()[0]
			actorR = dialogs[name_npc]["actors"][1].keys()[0]
			actors_gender[actorL] = (dialogs[name_npc]["actors"][0].values()[0])
			actors_gender[actorR] = (dialogs[name_npc]["actors"][1].values()[0])
			leftActor.texture = load("res://Actors/{actorL}.png".format({"actorL":actorL}))
			rightActor.texture = load("res://Actors/{actorR}.png".format({"actorR":actorR}))
		elif len(dialogs[name_npc]["actors"]) == 1:
			actorL = dialogs[name_npc]["actors"][0].keys()[0]
			actors_gender[actorL] = (dialogs[name_npc]["actors"][0].values()[0])
			leftActor.texture = load("res://Actors/{actorL}.png".format({"actorL":actorL}))
	else:
		if len(cutscene_actors) >= 2:
			actorL = cutscene_actors[0].keys()[0]
			actorR = cutscene_actors[1].keys()[0]
			actors_gender[actorL] = cutscene_actors[0].values()[0]
			actors_gender[actorR] = cutscene_actors[1].values()[0]
			leftActor.texture = load("res://Actors/{actorL}.png".format({"actorL":actorL}))
			rightActor.texture = load("res://Actors/{actorR}.png".format({"actorR":actorR}))

		elif len(cutscene_actors) == 1:
			actorL = cutscene_actors[0].keys()[0]
			actors_gender[actorL] = cutscene_actors[0].values()[0]
			leftActor.texture = load("res://Actors/{actorL}.png".format({"actorL":actorL}))
	
	if line["char"] == actorL:
		name_tag_panel.position = Vector2(120, name_tag_panel.position.y)
		name_tag.text = line["char"]
	
	elif line["char"] == actorR:
		name_tag_panel.position = Vector2(890, name_tag_panel.position.y)
		name_tag.text = line["char"]
	
	else:
		name_tag_panel.hide()
	
	var current_char_gender = actors_gender[line["char"]]
	if current_char_gender == "female":
		audio_player.stream = female_typing
	else:
		audio_player.stream = male_typing
	set_process_input(true)
	type_timer.start()


func _option(options_dict:Dictionary):
	#handle options
	for option in options_dict.keys():
		var option_gui = load("res://Dialogue/option.tscn").instantiate()
		if len(special_var)>0:
			option_gui.special_var = special_var[option]
		option_gui.option_text = option
		option_gui.update_text()
		options.add_child(option_gui)
		option_gui.connect_func()
	for i in range(options.get_child_count()):
		var button = options.get_child(i) as Button
		if i > 0:
			button.focus_neighbor_top = options.get_child(i - 1).get_path()
		if i < options.get_child_count() - 1:
			button.focus_neighbor_bottom = options.get_child(i + 1).get_path()
	is_option = true


func _chosen_option(key:String, special_key):
	is_option = false
	if quest != null and special_key == "accept":
		# GameData.add_quest(quest, quest_type, objective, amount)
		QuestManager.set_ongoing_quests(quest)
		get_parent().get_node("Menu").update()
	
	var idx = current_dialog_index +1
	for d in line["options"][key]:
		var dict = {"dialogue": d["dialogue"], "char":d["char"]}
		lines.insert(idx, dict)
		idx +=1
	for child in options.get_children():
		child.queue_free()
	current_dialog_index +=1
	line = lines[current_dialog_index]
	current_text = ""
	special_var = {}
	type_timer.start()
	

func _on_typing_timeout():

	if "options" in line.keys() and current_text.length() >= line["dialogue"].length():
		_option(line["options"])
		type_timer.stop()
	elif current_text.length() < line["dialogue"].length():
		current_text += line["dialogue"][current_text.length()]
		dial_text.text = current_text
		if not audio_player.is_playing():
			audio_player.play()
	
	else:
		type_timer.stop()
		line = lines[current_dialog_index]


func close():
	visible = false
	current_text = ""
	dial_text.text = current_text
	current_dialog_index = 0
	leftActor.texture=null
	rightActor.texture=null
	get_tree().paused = false
	for canvas in get_node("/root/World/CanvasLayer").get_children():
		if canvas != self and canvas.name not in ["ShopGUI", "Menu", "Portrait", "Popup"]:
			canvas.visible = true
	
	dialogue_finished.emit()
	set_process_input(false)

func _input(event):
	if event.is_action_pressed("run"):
		type_timer.wait_time = 0.01
	elif event.is_action_released("run"):
		type_timer.wait_time = type_speed
	if event.is_action_released("interact") and type_timer.is_stopped() and !is_finished_talking and !is_option:
		current_dialog_index +=1
		if current_dialog_index == len(lines):
			close()
			return
		elif current_dialog_index > len(lines):
			is_finished_talking = true


		else:
			line = lines[current_dialog_index]
			current_text = ""
			#put change char portrait here
			if line["char"] != actorL and line["char"] != actorR:
				actorR = line["char"]
				rightActor.texture = load("res://Actors/{actorR}.png".format({"actorR":actorR}))
				name_tag_panel.position = Vector2(890, name_tag_panel.position.y)
				name_tag.text = line["char"]
			elif line["char"] == actorL:
				name_tag_panel.position = Vector2(120, name_tag_panel.position.y)
				name_tag.text = line["char"]
			else:
				name_tag_panel.position = Vector2(890, name_tag_panel.position.y)
				name_tag.text = line["char"]
			
			var current_char_gender = actors_gender[line["char"]]
			if current_char_gender == "female":
				audio_player.stream = female_typing
			else:
				audio_player.stream = male_typing
			
			type_timer.start()
	
	
	if is_option:
		var focus = get_viewport().gui_get_focus_owner()
		if event.is_action_pressed("ui_up"):
			if focus == null:
				var top_option = options.get_children().front() as  Button
				top_option.grab_focus()
			else:
				var option = get_node(focus.focus_neighbor_top) as Button
				option.grab_focus()
		elif event.is_action_pressed("ui_down"):
			if focus == null:
				var bottom_option = options.get_children().back()
				bottom_option.grab_focus()
			else:
				var option = get_node(focus.focus_neighbor_bottom) as Button
				option.grab_focus()

func narator_starter():
	pass
