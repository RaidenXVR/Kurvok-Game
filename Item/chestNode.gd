extends Node2D

class_name ItemHolder

@export var items:Array[Vector2]
@export var chest_name: String
@export var chest_texture: Texture2D
@export var is_chest: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim:AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = chest_texture
	if is_chest:
		if GameData.get_chest_state(chest_name):
			sprite.frame = 88
			
	else:
		sprite.hframes = 1
		sprite.vframes = 1
		sprite.frame = 0
		$AnimationPlayer.active = false
	

func collect():

	if GameData.get_chest_state(chest_name):
		return
	GameData.set_chest_state(chest_name, true)
	if is_chest:
		anim.play("open")
	for item in items:
		var invItem = InventoryItems.new()
		invItem.init(str(item.x), int(item.y))
		# GameData.player_inventory.insert(invItem)
		GameData.player_inventory.insert(invItem)
