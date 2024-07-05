extends Resource

class_name Inventory

signal updated
signal heal_player(amount)

@export var consume_slots: Array[InventorySlot]
@export var key_slots:Array[InventorySlot]
@export var equip_slots:Array[InventorySlot]

var inv_node
var player_node
var current_tab:String = "consumables"

func _connect_to_player(node):
	inv_node = node
	player_node = inv_node.get_parent().get_parent().get_node("Player")
	connect("heal_player", player_node.heal)

func insert(item: InventoryItems):
	if item.category == "consumable":
		var itemSlots = consume_slots.filter(func(slot):return slot != null and slot.item != null and slot.item.item_id == item.item_id)

		if !itemSlots.is_empty() and !itemSlots[0].amount == itemSlots[0].maxAmount:
			itemSlots[0].amount += item.amount
			
			if itemSlots[0].amount >= itemSlots[0].maxAmount:
				handle_more_than_max(itemSlots[0], item)
		
		else:
			var emptySlots = consume_slots.filter(func(slot): return slot.item==null)
			if !emptySlots.is_empty():
				emptySlots[0].item = item
				emptySlots[0].amount = item.amount
				emptySlots[0].maxAmount = 20
			
				if emptySlots[0].amount > emptySlots[0].maxAmount:
					handle_more_than_max(emptySlots[0], item)

	QuestManager.check_target(item.item_id, item.amount)
	updated.emit()

func use_item(index:int):
	"""
	use_item: function used to use item for player.
	index: takes integer value of the slot clicked by the player
	return: void
	"""
	var item = consume_slots[index].item
	if item == null: return
	for key in item.effects.keys():
		if key =="heal": 
			emit_signal("heal_player", item.effects[key])
	if item.category == "consumable":
		consume_slots[index].amount -=1
		if consume_slots[index].amount <=0:
			# GameData.update_item(consume_slots[index], index)
			consume_slots[index].item = null

	QuestManager.check_target(item.item_id, -1)

	updated.emit()


func remove(item_id, amount):
	var relevant_item_slots: Array = []
	var item_json = GameData.json_getter("items", "Item")
	if item_json[item_id]["category"] == "consumable":
		for slot in consume_slots:
			if slot.item != null:
				if slot.item.item_id == item_id:
					relevant_item_slots.append(slot)
		_rem_item(relevant_item_slots, amount)
		QuestManager.check_target(item_id, -amount)

	updated.emit()

func _rem_item(relevant_item_slots, amount):
	while !relevant_item_slots.is_empty() and amount > 0:
		var slot = relevant_item_slots[0]
		amount -= slot.amount
		if amount <= 0:
			slot.amount  = -amount  # Set remaining amount
			if slot.amount <=0 :
				slot.item = null
			break
		else:
			slot.amount = 0
			slot.item = null
			relevant_item_slots.remove_at(0)


func handle_more_than_max(last_slot, item):

	var remainder = last_slot.amount - last_slot.maxAmount
	last_slot.amount = last_slot.maxAmount
	
	while remainder > 0:
		var emptySlots = consume_slots.filter(func(slot): return slot.item == null)
		if emptySlots.is_empty():
			break  # No more empty consume_slots, stop the loop

		var currentSlot = emptySlots[0]
		currentSlot.item = item
		currentSlot.item.texture = load(item.texture)

		if item.category == "equip" or item.category == "key":
			currentSlot.maxAmount = 1
		else:
			currentSlot.maxAmount = 20

		currentSlot.amount = min(remainder, currentSlot.maxAmount)  # Ensure amount doesn't exceed max
		remainder -= currentSlot.amount

func change_current_tab(what_tab:String):
	current_tab = what_tab.to_lower()