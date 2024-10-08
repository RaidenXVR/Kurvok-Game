extends Control


@onready var inventory: Inventory = GameData.player_inventory
@onready var slots: Array = $TabContainer/Consumables/Slots.get_children()
@onready var tab_container: TabContainer = get_node("TabContainer")
@onready var item_icon: TextureRect = $TabContainer/Consumables/ItemIcon

signal tab_changed(what_tab)

signal opened
signal closed

var is_open:bool = false
var current_tab: String = "consumables"


func _ready():
	inventory.updated.connect(update)
	inventory._connect_to_player(self)
	connect("tab_changed", inventory.change_current_tab)
	update()

func update():
	if current_tab == "consumables":
		for i in range(min(inventory.consume_slots.size(), slots.size())):
			slots[i].update(inventory.consume_slots[i], inventory)
			# GameData.update_item(inventory.consume_slots[i],i)
	
	elif current_tab == "key items":
		for i in range(min(inventory.key_slots.size(), slots.size())):
			slots[i].update(inventory.key_slots[i], inventory)
			# GameData.update_item(inventory.key_slots[i],i)
	
	elif current_tab == "equipment":
		for i in range(min(inventory.equip_slots.size(), slots.size())):
			slots[i].update(inventory.equip_slots[i], inventory)
			# GameData.update_item(inventory.equip_slots[i],i)

func open():
	visible = true
	is_open = true
	opened.emit()
	
func close():
	visible = false
	is_open = false
	closed.emit()


func _insert_item(item_id,amount):
	var temp_item = InventoryItems.new(item_id, amount)
	inventory.insert(temp_item)


func return_relevant_items(item_id):
	var rel_slot = []
	for slot in inventory.slots:
		if slot.item != null:
			if slot.item.item_id == item_id:
				rel_slot.append(slot)
	return rel_slot



func _on_tab_container_tab_changed(tab:int):
	var tab_title = tab_container.get_tab_title(tab)
	if tab_title not in ["Map", "Status", "Quests"]:
		var slots_path = "/root/World/CanvasLayer/Menu/TabContainer/%s/Slots"%[tab_title] 
		slots = get_node(slots_path).get_children()
	emit_signal("tab_changed",	tab_title.to_lower())
	current_tab = tab_title.to_lower()
	update()


func update_item_desc(index):
	var selected_slot:InventorySlot
	if current_tab == "consumables":
		selected_slot = inventory.consume_slots[index]
	elif current_tab == "key items":
		selected_slot = inventory.key_slots[index]
	elif current_tab == "equipment":
		selected_slot = inventory.equip_slots[index]
	

	item_icon.texture = load(selected_slot.item.texture)
