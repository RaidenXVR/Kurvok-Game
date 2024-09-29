extends Control

@onready var inventory: Inventory = GameData.player_inventory
@onready var consume_slots: Array = $ItemButton/Container/Slots.get_children()
@onready var key_slots: Array = $KeyItemButton/Container/Slots.get_children()
@onready var equip_slots: Array = $EquipButton/Container/Slots.get_children()
@onready var consume_cont: Control = $ItemButton/Container
@onready var key_cont: Control = $KeyItemButton/Container
@onready var equip_cont: Control = $EquipButton/Container
@onready var status_cont: Control = $StatusButton/Container
@onready var quest_main_cont: Control = $QuestButton/Container
@onready var main_quest_cont: VBoxContainer = $"QuestButton/Container/TabContainer/Main Quest/VBoxContainer"
@onready var side_quest_cont: VBoxContainer = $"QuestButton/Container/TabContainer/Side Quests/VBoxContainer"


signal opened
signal closed
signal open_popup(text:String)

var is_open:bool = false
var is_menu_open:bool = false
var is_status_open: bool = false
var current_tab = "status"

func _ready():
	inventory.updated.connect(update)
	inventory._connect_to_player(self)
	update()

func update():
	for i in range(min(inventory.consume_slots.size(), consume_slots.size())):
		consume_slots[i].update(inventory.consume_slots[i], inventory)

	for i in range(min(inventory.key_slots.size(), key_slots.size())):
		key_slots[i].update(inventory.key_slots[i], inventory)

	for i in range(min(inventory.equip_slots.size(), equip_slots.size())):
		equip_slots[i].update(inventory.equip_slots[i], inventory)


func open():
	visible = true
	is_menu_open = true
	_on_status_button_button_down()
	opened.emit()
	
func close():
	visible = false
	is_open = false
	is_menu_open = false
	closed.emit()


func _insert_item(item_id,amount):
	var temp_item = InventoryItems.new()
	temp_item.init(item_id, amount)
	inventory.insert(temp_item)


func return_relevant_items(item_id):
	var rel_slot = []
	for slot in inventory.slots:
		if slot.item != null:
			if slot.item.item_id == item_id:
				rel_slot.append(slot)
	return rel_slot
	
func update_item_desc(index):
	var selected_slot:InventorySlot
	if current_tab == "consumable":
		selected_slot = inventory.consume_slots[index]
		$ItemButton/Container/ItemIcon.texture = load(selected_slot.item.texture)
		$ItemButton/Container/ItemDesc.text = selected_slot.item.description
	elif current_tab == "key items":
		selected_slot = inventory.key_slots[index]
		$KeyItemButton/Container/ItemIcon.texture = load(selected_slot.item.texture)
		$KeyItemButton/Container/ItemDesc.text = selected_slot.item.description
	elif current_tab == "equipment":
		selected_slot = inventory.equip_slots[index]
		$EquipButton/Container/ItemIcon.texture = load(selected_slot.item.texture)
		$EquipButton/Container/ItemDesc.text = selected_slot.item.description
	

func _on_item_button_button_down():
	if not is_open or not current_tab == "consumable":
		update()
		is_open = true
		status_cont.visible = false
		key_cont.visible = false
		equip_cont.visible = false
		current_tab = "consumable"
		consume_cont.visible = true
	else:
		_on_status_button_button_down()

func _on_key_item_button_button_down():
	if not is_open or not current_tab == "key items":
		update()
		is_open = true
		status_cont.visible = false
		consume_cont.visible = false
		equip_cont.visible = false
		current_tab = "key items"
		key_cont.visible = true
	else:
		_on_status_button_button_down()


func _on_equip_button_button_down():
	if not is_open or not current_tab == "equipment":
		update()
		is_open = true
		status_cont.visible = false
		key_cont.visible = false
		consume_cont.visible = false
		current_tab = "equipment"
		equip_cont.visible = true
	else:
		_on_status_button_button_down()


func _on_status_button_button_down():

		is_open = false
		status_cont.visible = true
		key_cont.visible = false
		consume_cont.visible = false
		equip_cont.visible = false
		quest_main_cont.visible = false
		current_tab = "status"
		$StatusButton/Container/VBoxContainer/HP.text ="HP: "+ str(GameData.player_stats.hp) +"/"+str(GameData.player_stats.mhp)
		$StatusButton/Container/VBoxContainer/MP.text = "Mana: "+str(GameData.player_stats.mana) +"/"+str(GameData.player_stats.max_mana)
		$StatusButton/Container/VBoxContainer/Atk.text ="Attack: "+ str(GameData.player_stats.att)
		$StatusButton/Container/VBoxContainer/Def.text = "Defense: "+str(GameData.player_stats.def)
		$StatusButton/Container/VBoxContainer/Money.text = "Money: "+str(GameData.money) +" Chrone"

		


func _on_quest_button_button_down():
	if not is_open or not current_tab == "quest":
		update()
		is_open = true
		status_cont.visible = false
		key_cont.visible = false
		consume_cont.visible = false
		equip_cont.visible = false
		current_tab = "quest"
		_on_quest_tab_selected(0)
		quest_main_cont.visible = true
	else:
		_on_status_button_button_down()
		free_quest()


func free_quest():
	var main_on_cont = $"QuestButton/Container/TabContainer/Main Quest/VBoxContainer/OngoingContainer"
	var main_com_cont = $"QuestButton/Container/TabContainer/Main Quest/VBoxContainer/CompletedContainer"
	var side_on_cont = $"QuestButton/Container/TabContainer/Side Quests/VBoxContainer/OngoingContainer"
	var side_com_cont = $"QuestButton/Container/TabContainer/Side Quests/VBoxContainer/CompletedContainer"
	var main_on_butt = $"QuestButton/Container/TabContainer/Main Quest/VBoxContainer/OngoingContainer/Ongoing"
	var main_com_butt = $"QuestButton/Container/TabContainer/Main Quest/VBoxContainer/CompletedContainer/Completed"
	var side_on_butt = $"QuestButton/Container/TabContainer/Side Quests/VBoxContainer/OngoingContainer/Ongoing"
	var side_com_butt = $"QuestButton/Container/TabContainer/Side Quests/VBoxContainer/CompletedContainer/Completed"
	
	for child in main_on_cont.get_children():
		if child != main_on_butt:
			child.queue_free()
	
	for child in main_com_cont.get_children():
		if child != main_com_butt:
			child.queue_free()
	
	for child in side_on_cont.get_children():
		if child != side_on_butt:
			child.queue_free()
	
	for child in side_com_cont.get_children():
		if child != side_com_butt:
			child.queue_free()

func _on_quest_tab_selected(tab):
	#TODO: Fix quests list
	match tab:
		0:
			
			var main_ongoing_quest_butt: Button = $"QuestButton/Container/TabContainer/Main Quest/VBoxContainer/OngoingContainer/Ongoing"
			if len(main_ongoing_quest_butt.get_children())>1:
				return
			
			if QuestManager.current_main_quest:
				main_ongoing_quest_butt.text = QuestManager.current_main_quest.main_quest_name
				for quest in QuestManager.current_main_quest.on_going_quests:
					var butt = Button.new()
					butt.text = quest.quest_name
					butt.visible = false
					butt.set_meta("quest_name", quest.quest_name)
					butt.set_meta("desc",quest.quest_description)
					butt.set_meta("target", quest.target)
					butt.set_meta("current_target", quest.current_target_amount)
					butt.connect("pressed", func(): _on_quest_clicked(butt))
					main_ongoing_quest_butt.get_parent().add_child(butt)
				
				for quest in QuestManager.current_main_quest.completed_quests:
					var butt = Button.new()
					butt.text = quest.quest_name
					butt.visible = false
					butt.set_meta("quest_name", quest.quest_name)
					butt.set_meta("desc",quest.quest_description)
					butt.set_meta("target", quest.target)
					butt.set_meta("current_target", quest.current_target_amount)
					butt.connect("pressed", func(): _on_quest_clicked(butt))
					main_ongoing_quest_butt.get_parent().add_child(butt)
			
			if QuestManager.completed_main_quest:
				var completed_main_quest_cont:VBoxContainer = $"QuestButton/Container/TabContainer/Main Quest/VBoxContainer/CompletedContainer"
				for quest in QuestManager.completed_main_quest:
					var butt = Button.new()
					butt.text = quest.main_quest_name
					butt.visible = false
					butt.set_meta("desc",quest.quest_description)
					butt.connect("pressed", func(): _on_quest_clicked(butt))
					completed_main_quest_cont.add_child(butt)
		
		1:
			var side_ongoing_quest_cont:VBoxContainer = $"QuestButton/Container/TabContainer/Side Quests/VBoxContainer/OngoingContainer"
			var side_completed_quest_cont:VBoxContainer = $"QuestButton/Container/TabContainer/Side Quests/VBoxContainer/CompletedContainer"
			
			if len(side_ongoing_quest_cont.get_children())>1:
				return

			for q in QuestManager.ongoing_quests:
				var butt = Button.new()
				butt.text = q.quest_name
				butt.visible = false
				butt.set_meta("quest_name", q.quest_name)
				butt.set_meta("desc",q.quest_description)
				butt.set_meta("target", q.target)
				butt.set_meta("current_target", q.current_target_amount)
				butt.connect("pressed", func(): _on_quest_clicked(butt))
				side_ongoing_quest_cont.add_child(butt)
		
			for q in QuestManager.completed_quests:
				var butt = Button.new()
				butt.text = q.quest_name
				butt.visible = false
				butt.set_meta("quest_name", q.quest_name)
				butt.set_meta("desc",q.quest_description)
				butt.set_meta("target", q.target)
				butt.set_meta("current_target", q.current_target_amount)
				butt.connect("pressed", func(): _on_quest_clicked(butt))
				side_completed_quest_cont.add_child(butt)
				
			
func _on_quest_button_toggled(toggled_on, extra_arg_0:NodePath):
	if toggled_on:
		var cont = get_node(extra_arg_0)
		for child in cont.get_children():
			child.visible = true
	
	else:
		var cont = get_node(extra_arg_0)
		var butt1 = get_node(str(extra_arg_0)+"/Ongoing")
		var butt2 = get_node(str(extra_arg_0)+"/Completed")
		for child in cont.get_children():
			if not (child == butt1 or child == butt2):
				child.visible = false
				
				
func _on_quest_clicked(button_node:Button):
	var quest_name_label:Label = $QuestButton/Container/Details/QuestName
	var desc_label:Label = $QuestButton/Container/Details/Description
	var target_cont:VBoxContainer = $QuestButton/Container/Details/Targets
	
	quest_name_label.text = button_node.get_meta("quest_name")
	desc_label.text = button_node.get_meta("desc")
	var targets = button_node.get_meta("target")
	var current_targets = button_node.get_meta("current_target")
	for target in targets:
		var lb = Label.new()
		lb.add_theme_font_size_override("font_size", 25)
		var t: String = ""
		if target.is_valid_int():
			var item_dict = GameData.json_getter("items", "Item")
			t = item_dict[target]["name"]
		else:
			t = target
		
		lb.text = t +":   \t"+ str(current_targets[target])+"/"+str(targets[target])
		
		target_cont.add_child(lb)


func _on_save_button_button_down():
	GameData.save_game()
	close()
	open_popup.emit("Game Saved")

func _on_set_skills_button_down():
	$StatusButton/Container/SetSkills/SetSkillPopup.visible = true
	$StatusButton/Container/SetSkills/SetSkillPopup/EquippedSkill1.grab_focus()
	is_status_open = true
