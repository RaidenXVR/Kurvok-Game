extends StaticBody2D

class_name Shop

@export var item_ids: Array[String]
@export var merchant_sprite: Texture2D

func open_shop():
	get_tree().paused = true
	var shop_gui = get_tree().root.get_node("/root/World/CanvasLayer/ShopGUI")
	var canvas = get_tree().root.get_node("/root/World/CanvasLayer")
	shop_gui.set_items(item_ids)
	shop_gui.visible = true
	var texture_merchant = shop_gui.get_node("MerchantSprite") as TextureRect
	texture_merchant.texture = merchant_sprite
	for gui in canvas.get_children():
		if not gui == shop_gui:
			gui.visible = false

