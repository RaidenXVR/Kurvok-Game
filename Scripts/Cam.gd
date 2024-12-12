extends Camera2D


func _ready():
	
	var world: TileMap = load(GameData.current_map).instantiate()
	var mapRect = world.get_used_rect()
	var mapSizePx = mapRect.size * 48
	limit_right = mapSizePx.x
	limit_bottom = mapSizePx.y

func load_cam(map: TileMap):
	var mapRect = map.get_used_rect()
	var mapSizePx = mapRect.size * 48
	limit_right = mapSizePx.x
	limit_bottom = mapSizePx.y

	pass



