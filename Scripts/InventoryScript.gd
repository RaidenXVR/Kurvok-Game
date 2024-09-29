extends Resource

class_name Inventory

signal updated
signal heal_player(amount)
signal item_get(text_string)

@export var consume_slots: Array[InventorySlot]
@export var key_slots:Array[InventorySlot]
@export var equip_slots:Array[InventorySlot]

var inv_node
var player_node
var current_tab:String = "consumables"
var last_equipped: int = 0

func _init():
	for i in range(35):
		var slot1 = InventorySlot.new()
		slot1.maxAmount = 20
		var slot2 = InventorySlot.new()
		slot2.maxAmount = 1
		var slot3 = InventorySlot.new()
		slot3.maxAmount = 1
		
		consume_slots.append(slot1)
		key_slots.append(slot2)
		equip_slots.append(slot3)
		
		


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
	
	elif item.category == "equipment":
		var emptySlots = equip_slots.filter(func(slot):return slot.item == null)
		emptySlots[0].item = item
		emptySlots[0].amount = item.amount
	
	elif item.category == "key":
		var emptySlots = key_slots.filter(func(slot):return slot.item == null)
		emptySlots[0].item = item
		emptySlots[0].amount = item.amount
	
	QuestManager.check_target(item.item_id, item.amount)
	updated.emit()
	item_get.emit("Got "+item.name+" x"+str(item.amount))

func use_item(index:int, used_item_category:String):
	"""
	use_item: function used to use item for player.
	index: takes integer value of the slot clicked by the player
	return: void
	"""
	if used_item_category == "consumable":
		var item = consume_slots[index].item
		if item == null: return
		#for key in item.effects.keys():
			#if key =="heal": 
				#emit_signal("heal_player", item.effects[key])
		for key in item.effects.keys():
			if key == "heal":
				GameData.player_stats.hp += item.effects["heal"]
			elif key == "buff":
				GameData.update_stats(item.effects["buff"], item.effects["duration"])
			elif key == "duration":
				pass
		consume_slots[index].amount -=1
		if consume_slots[index].amount <=0:
			consume_slots[index].item = null

		QuestManager.check_target(item.item_id, -1)
	
	elif used_item_category == "equipment":
		var slot = equip_slots[index]
		var item = slot.item
		var sub_category = item.sub_category
		if sub_category == "weapon":
			if not item.is_equipped:
				if GameData.weapon_equip != null:
					var slot_before = equip_slots.filter(func(s): return s.item == GameData.weapon_equip)
					if slot_before:
						slot_before[0].is_equipped = false
				GameData.weapon_equip = item
				item.is_equipped = true
			else:
				GameData.weapon_equip = null
				item.is_equipped = false
		
		elif sub_category == "armor":
			var key_armor = key_slots.filter(func(sl): return sl.item != null and sl.item.item_id == "5")
			if key_armor:
				if item.is_equipped:
					if slot.item == GameData.armor_equip1:
						GameData.armor_equip1 = null
						item.is_equipped = false
					elif slot.item == GameData.armor_equip2:
						GameData.armor_equip2 = null
						item.is_equipped = false
					elif slot.item == GameData.armor_equip3:
						GameData.armor_equip3 = null
						item.is_equipped = false
					
					GameData.update_stats(item.effects["buff"], 0, true)
				else:
					match last_equipped:
						1:
							if GameData.armor_equip1 == null:
								var slot_before = equip_slots.filter(func(s): return s.item == GameData.armor_equip1)
								if slot_before:
									slot_before[0].is_equipped = false
							GameData.armor_equip2 = slot.item
							item.is_equipped = true
							last_equipped += 1
						2:
							if GameData.armor_equip2 == null:
								var slot_before = equip_slots.filter(func(s): return s.item == GameData.armor_equip2)
								if slot_before:
									slot_before[0].is_equipped = false
							GameData.armor_equip3 = slot.item
							item.is_equipped = true
							last_equipped += 1
						_:
							if GameData.armor_equip3 == null:
								var slot_before = equip_slots.filter(func(s): return s.item == GameData.armor_equip3)
								if slot_before:
									slot_before[0].is_equipped = false
							GameData.armor_equip1 = slot.item
							item.is_equipped = true
							last_equipped = 1
					GameData.update_stats(item.effects["buff"])
			
			else:
				if not item.is_equipped:
					if GameData.armor_equip1 != null:
						var slot_before = equip_slots.filter(func(s): return s.item == GameData.armor_equip1)
						if slot_before:
							slot_before[0].is_equipped = false
					GameData.armor_equip1 = item
					item.is_equipped = true
				else:
					GameData.armor_equip1 = null
					item.is_equipped = false
					GameData.update_stats(item.effects["buff"], 0, true)
					
		pass
	
	elif used_item_category == "key":
		pass

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
		currentSlot.item.texture = item.texture

		if item.category == "equip" or item.category == "key":
			currentSlot.maxAmount = 1
		else:
			currentSlot.maxAmount = 20

		currentSlot.amount = min(remainder, currentSlot.maxAmount)  # Ensure amount doesn't exceed max
		remainder -= currentSlot.amount

#func change_current_tab(what_tab:String):
	#current_tab = what_tab.to_lower()


func get_amount_by_id(item_id):
	var slots: Array = consume_slots.filter(func(slt): return slt.item != null and slt.item.item_id == item_id)
	var amnt = 0
	if not slots.is_empty():
		for a in slots:
			amnt +=int(a.amount)
	
	return amnt
