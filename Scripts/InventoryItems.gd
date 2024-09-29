extends Resource

class_name InventoryItems



@export var name: String = ""
@export var texture: String
@export var category: String = ""
@export var effects:Dictionary
@export var item_id: String
@export var amount:int
@export var description:String
@export var sub_category: String
@export var is_equipped: bool = false
var item_data

func init(id, am):
	item_id = id
	amount = am
	
	var items_json = FileAccess.get_file_as_string("res://Item/items.json")
	item_data = JSON.parse_string(items_json)

	var found_item
	if item_data.has(str(item_id)):
		found_item =  item_data[str(item_id)]
		
	else:
		return

	name = found_item["name"]
	category = found_item["category"]
	effects = found_item["effect"]
	texture = found_item["texture"]
	description = found_item["description"]
	
	if category == "equipment":
		sub_category = found_item["sub_category"]
	

func effect():
	pass

func make_item_from_id(id, amn):
	item_id = id
	amount = amn
	
	var items_json = FileAccess.get_file_as_string("res://Item/items.json")
	item_data = JSON.parse_string(items_json)
	
	var found_item
	if item_data.has(str(item_id)):
		found_item =  item_data[str(item_id)]
	else:
		return null

	name = found_item["name"]
	category = found_item["category"]
	effects = found_item["effect"]
	texture = found_item["texture"]
	
	return self
