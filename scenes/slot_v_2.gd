extends TextureButton

@onready var itemSprite:Sprite2D = $ItemSprite
@onready var itemAmount: Label = $Amount
@export var index:int
var inventory: Inventory

signal item_focused(index)

func _ready():
	connect("item_focused", get_node("/root/World/CanvasLayer/Inventory").update_item_desc)

func update(slot: InventorySlot, _inventory: Inventory):
	self.inventory = _inventory
	if slot.item == null:
		disabled = true
		itemSprite.visible = false
		itemAmount.visible = false
	
	else:
		disabled = false
		itemSprite.texture = load(slot.item.texture)
		itemSprite.visible = true

		if slot.amount != 0:
			itemAmount.visible = true
			itemAmount.text = str(slot.amount)


	if itemSprite.texture != null:
		var size_x = float(itemSprite.texture.get_size().x)
		if size_x > custom_minimum_size.x:
			if int(size_x) % 16 ==0:
				itemSprite.scale.x =16/size_x
				itemSprite.scale.y = 16/size_x



func _on_pressed():
	
	inventory.use_item(index)
	inventory.updated.emit()
	


func _on_focus_entered():
	if disabled:
		return
	emit_signal("item_focused", index)
