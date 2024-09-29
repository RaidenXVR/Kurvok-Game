extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var world: TileMap = load(GameData.current_map).instantiate()
	var mapRect = world.get_used_rect()
	var mapSizePx = mapRect.size * 48
	print(mapSizePx)
	limit_right = mapSizePx.x
	limit_bottom = mapSizePx.y
	



