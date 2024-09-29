extends Control

#buy tabs items
@onready var buy_tab: TabBar = $ShopContainer/Buy
@onready var buy_itemlist:ItemList = $ShopContainer/Buy/BuyList
@onready var buy_item_icon: TextureRect = $ShopContainer/Buy/ItemIcon
@onready var buy_item_name: Label = $ShopContainer/Buy/ItemName
@onready var buy_item_description: RichTextLabel = $ShopContainer/Buy/ItemDescription
@onready var buy_item_cost: Label = $ShopContainer/Buy/Cost
@onready var buy_item_effects: RichTextLabel = $ShopContainer/Buy/EffectLabel
@onready var buy_item_money: Label = $ShopContainer/Buy/Money
@onready var buy_item_posess:Label = $ShopContainer/Buy/Posession

#sell tabs items
@onready var sell_tab: TabBar = $ShopContainer/Sell
@onready var sell_itemlist:ItemList = $ShopContainer/Sell/SellList
@onready var sell_item_icon: TextureRect = $ShopContainer/Sell/ItemIcon
@onready var sell_item_name: Label = $ShopContainer/Sell/ItemName
@onready var sell_item_description: RichTextLabel = $ShopContainer/Sell/ItemDescription
@onready var sell_item_cost: Label = $ShopContainer/Sell/Cost
@onready var sell_item_effects: RichTextLabel = $ShopContainer/Sell/EffectLabel
@onready var sell_item_money: Label = $ShopContainer/Sell/Money
@onready var sell_item_posess: Label = $ShopContainer/Sell/Posession


#other
@onready var inven = get_tree().root.get_node("/root/World/CanvasLayer/Menu")
@onready var canvas = get_parent()

var _item_ids : Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	set_process_input(false)

func set_items(item_ids:Array[String]):
	buy_item_money.text = str(GameData.money)
	canvas.is_shopping = true
	get_tree().paused = true
	buy_tab.grab_focus()
	_item_ids = item_ids
	var items = GameData.json_getter("items","Item")
	var items_array: Array = []
	for item in item_ids:
		items_array.append({str(item):items[item]})

	for idx in range(items_array.size()):
		buy_itemlist.add_item(items[items_array[idx].keys()[0]]["name"])
		buy_itemlist.set_item_metadata(idx, items_array[idx].keys()[0])
		var cost = items[items_array[idx].keys()[0]]["buy"]
		check_money_to_item(idx, cost)
		
	set_process_input(true)

func selected_item_buy(index:int):
	var item_id_selected = buy_itemlist.get_item_metadata(index)
	inven._insert_item(item_id_selected, 1)
	var items = GameData.json_getter("items","Item")
	GameData.decrease_money(items[item_id_selected]["buy"])
	buy_item_money.text = str(GameData.money)
	check_money_to_item(index, items[item_id_selected]["buy"])
	var rel_item = GameData.items_id_consum.filter(func(it): return it.keys()[0] == item_id_selected)
	var posession = 0
	for p in rel_item:
		posession += p[item_id_selected] 
	buy_item_posess.text = "Owned: "+ str(posession)

func _on_buy_list_item_selected(index:int):
	buy_item_effects.clear()
	buy_item_description.clear()
	var item_id_selected = buy_itemlist.get_item_metadata(index)
	var items_json = GameData.json_getter("items","Item")
	var item = items_json[item_id_selected]
	buy_item_icon.texture = load(item["texture"])
	buy_item_name.text = item["name"]
	buy_item_cost.text = "Price: "+str(item["buy"])
	buy_item_description.append_text(item["description"])
	var rel_item = GameData.items_id_consum.filter(func(it): return it.keys()[0] == item_id_selected)
	var posession = 0
	for p in rel_item:
		posession += p[item_id_selected] 
	
	buy_item_posess.text = "Owned: "+ str(posession)
	for effect in item["effect"].keys():
		if effect == "heal":
			buy_item_effects.append_text("Heal the player by %s" %[item["effect"][effect]])
		else:
			var buff:String = str(item["effect"][effect]) 
			if !buff.begins_with("-"):
				buff = "+"+buff
			buy_item_effects.append_text("[p]%s %s[/p]" % [effect.to_upper(),buff ])

func _input(event):

	if event.is_action_pressed("ui_cancel"):
		var shop_gui = get_tree().root.get_node("/root/World/CanvasLayer/ShopGUI")
		get_tree().paused = false
		shop_gui.visible = false
		set_process_input(false)
		canvas.is_shopping = false
		get_tree().paused = false
		for item in range(buy_itemlist.item_count):
			buy_itemlist.remove_item(0)

		var healthbar_gui = get_tree().root.get_node("/root/World/CanvasLayer/PlayerHealthBar")
		healthbar_gui.visible = true
		var money_gui = get_tree().root.get_node("/root/World/CanvasLayer/MoneyUI")
		money_gui.visible = true


func set_sell_items():
	var slots = GameData.items_id_consum
	var items = GameData.json_getter("items","Item")
	var items_dict: Dictionary = {}
	for item in slots:
		if not items_dict.has(item.keys()[0]):
			items_dict[item.keys()[0]] = item[item.keys()[0]]
		else:
			items_dict[item.keys()[0]] += item[item.keys()[0]]

	var idx = 0
	for item in items_dict.keys():
		sell_itemlist.add_item(items[item]["name"])
		sell_itemlist.set_item_metadata(idx, {item:items_dict[item]})

func selected_item_sell(index:int):
	var inv = get_parent().get_node("Inventory")
	var items_json = GameData.json_getter("items","Item")
	var metadata_item = sell_itemlist.get_item_metadata(index)
	var the_amount = metadata_item[metadata_item.keys()[0]] -1 
	sell_itemlist.set_item_metadata(index, {metadata_item.keys()[0]:the_amount})
	inv.inventory.remove(metadata_item.keys()[0],1)
	GameData.add_money(items_json[metadata_item.keys()[0]]["sell"])
	sell_item_posess.text = "Owned: "+str(the_amount)
	if the_amount <=0:
		sell_itemlist.remove_item(index)


func _on_shop_container_tab_changed(tab:int):
	if tab == 1:
		buy_item_posess.text = ""
		for item in range(sell_itemlist.item_count):
			sell_itemlist.remove_item(0)
		set_sell_items()
	if tab == 0:
		sell_item_posess.text = ""
		for item in range(buy_itemlist.item_count):
			buy_itemlist.remove_item(0)
		set_items(_item_ids)


func _on_sell_list_item_selected(index:int):
	sell_item_effects.clear()
	sell_item_description.clear()
	var item_id_selected = sell_itemlist.get_item_metadata(index).keys()[0]
	var items_json = GameData.json_getter("items","Item")
	var item = items_json[item_id_selected]
	sell_item_icon.texture = load(item["texture"])
	sell_item_name.text = item["name"]
	sell_item_cost.text = "Price: "+str(item["buy"])
	sell_item_description.append_text(item["description"])
	var rel_item = GameData.items_id_consum.filter(func(it): return it.keys()[0] == item_id_selected)
	var posession = 0
	for p in rel_item:
		posession += p[item_id_selected] 
	sell_item_posess.text = "Owned: "+str(posession)

	for effect in item["effect"].keys():
		if effect == "heal":
			sell_item_effects.append_text("Heal the player by %s" %[item["effect"][effect]])
		else:
			var buff:String = str(item["effect"][effect]) 
			if !buff.begins_with("-"):
				buff = "+"+buff
			sell_item_effects.append_text("[p]%s %s[/p]" % [effect.to_upper(),buff ])

func check_money_to_item(index:int, price:int):
	if GameData.money < price:
		buy_itemlist.set_item_disabled(index, true)
