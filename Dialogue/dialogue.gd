extends Control

signal trigger_quest(quest_name, q_type, objtv, amn)
signal check_quest_completion

var lines:Array 
var line
var actors:Array
var actorL
var actorR
var current_dialog_index:int
var current_text = ""
var type_speed = 0.05
var is_finished_talking: bool = true
var special_var: Dictionary = {}
var quest
var objective
var amount
var quest_type
var is_option: bool = false

@onready var leftActor = $LeftPortrait
@onready var rightActor = $RightPortrait
@onready var dial_text = $Panel/Label
@onready var type_timer = $TypingTimer
@onready var options = $Options
@onready var player_hpbar = get_tree().root.get_node("/root/World/CanvasLayer/PlayerHealthBar")
@onready var gold = get_tree().root.get_node("/root/World/CanvasLayer/MoneyUI")

func _ready():

	type_timer.connect("timeout",_on_typing_timeout)
	type_timer.wait_time = type_speed



func starter(dialog, name_npc:String, q = null):
	quest = q
	get_tree().paused = true
	visible = true
	is_finished_talking = false
	lines.clear()
	actors.clear()


	for canvas in get_node("/root/World/CanvasLayer").get_children():
		if canvas != self:
			canvas.visible = false


	for item in dialog:
		lines.append(item["dialogue"])
		actors.append(item["char"])
		if len(item["options"])>0:
			lines.append(item["options"])
		if item.has("special_var"):
			if !item["special_var"].is_empty():
				special_var = item["special_var"]
		

	current_dialog_index = 0
	line = lines[current_dialog_index]
	actorL = "Layla"
	actorR = name_npc

	leftActor.texture = load("res://Actors/{actorL}.png".format({"actorL":actorL}))
	rightActor.texture = load("res://Actors/{actorR}.png".format({"actorR":actorR}))
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
	if quest != null and special_key == "accept quest":
		# GameData.add_quest(quest, quest_type, objective, amount)
		QuestManager.set_ongoing_quests(quest)
		get_parent().get_node("Inventory").update()
	
	var idx = current_dialog_index +1
	for d in line[key]:
		lines.insert(idx, d["dialogue"])
		actors.insert(idx,d["char"])
		idx +=1
	for child in options.get_children():
		child.queue_free()
	current_dialog_index +=1
	line = lines[current_dialog_index]
	special_var = {}
	type_timer.start()
	

func _on_typing_timeout():
	if line is Dictionary:
		_option(line)
		type_timer.stop()
	elif current_text.length()<line.length():
		current_text += line[current_text.length()]
		dial_text.text = current_text
	else:
		type_timer.stop()
		line = lines[current_dialog_index]
		pass
	pass

func close():
	visible = false
	current_text = ""
	dial_text.text = current_text
	get_tree().paused = false
	for canvas in get_node("/root/World/CanvasLayer").get_children():
		if canvas != self and canvas.name not in ["ShopGUI", "Inventory", "Portrait"]:
			canvas.visible = true

func _input(event):
	if event.is_action_pressed("run"):
		type_timer.wait_time = 0.01
	elif event.is_action_released("run"):
		type_timer.wait_time = type_speed
	if event.is_action_pressed("interact") and type_timer.is_stopped() and !is_finished_talking and !is_option:
		current_dialog_index +=1
		if current_dialog_index == len(lines):
			close()
			return
		elif current_dialog_index > len(lines):
			is_finished_talking = true


		else:
			line = lines[current_dialog_index]
			current_text = ""
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


