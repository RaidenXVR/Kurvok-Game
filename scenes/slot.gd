extends Panel

@onready var invenBG:Sprite2D = $background
@onready var itemSprite:Sprite2D = $CenterContainer/Panel/item
@onready var itemAmount: Label = $CenterContainer/Panel/Label
var inventory: Inventory

func update(slot: InventorySlot, inv: Inventory):
	self.inventory = inv
	if !slot.item :
		invenBG.frame = 0
		itemSprite.visible = false
		itemAmount.visible = false
	else:
		invenBG.frame = 1
		itemSprite.visible = true
		itemSprite.texture = slot.item.texture
			
		if !slot.amount ==0 :
			itemAmount.visible = true
			itemAmount.text = str(slot.amount)
	if itemSprite.texture != null:
		var size_x = float(itemSprite.texture.get_size().x)
		if size_x > custom_minimum_size.x:
			if int(size_x) % 16 ==0:
				itemSprite.scale.x =16/size_x
				itemSprite.scale.y = 16/size_x
	

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			inventory.use_item(int(self.name.right(1))-1)
			inventory.updated.emit()
			

