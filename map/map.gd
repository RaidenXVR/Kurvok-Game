extends TileMap

@export var west_map: String
@export var east_map: String
@export var north_map: String
@export var south_map: String


func _on_west_point_body_entered(body:Node2D):
	if body is Player:
		var map = load(west_map).instantiate()
		var tp_area = map.get_node("EntryPoint/eastPoint")

		if tp_area != null:
			var player_node = get_node("/root/World/Player") as Player
			var tp_coor = tp_area.position
			tp_coor.x -= 25*tp_area.scale.x
			player_node.position = tp_coor
			get_parent().call_deferred("add_child", map)
			self.queue_free()


func _on_east_point_body_entered(body:Node2D):
	if body is Player:
		var map = load(east_map).instantiate()
		var tp_area = map.get_node("EntryPoint/westPoint")

		if tp_area != null:
			var player_node = get_node("/root/World/Player") as Player
			var tp_coor = tp_area.position
			tp_coor.x += 25*tp_area.scale.x
			player_node.position = tp_coor
			get_parent().call_deferred("add_child", map)
			self.queue_free()




