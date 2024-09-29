extends Resource

class_name InventorySlot

@export var item: InventoryItems
@export var amount : int
@export var maxAmount:int
var is_equipped: = false


func get_amount():
	return amount
