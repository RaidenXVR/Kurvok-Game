extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var world: TileMap = get_parent().get_parent().get_node("maps").get_child(0)

	
	var mapRect = world.get_used_rect()
	var tileSize = world.cell_quadrant_size
	var mapSizePx = mapRect.size * tileSize
	limit_left = 0
	limit_top = 0
	limit_right = mapSizePx.x
	limit_bottom = mapSizePx.y



