extends StaticBody2D

class_name WestEntry

func _on_west_point_body_entered(body:Node2D):
	if body is Player:

		var map = load(get_parent().get_parent().west_map).instantiate()
		var tp_area = map.get_node("EntryPoint/eastPoint")

		if tp_area != null:
			var player_node = get_node("/root/World/Player") as Player
			var tp_coor = tp_area.position
			tp_coor.x -= 25*tp_area.scale.x
			player_node.position = tp_coor
			var map_node = get_node("/root/World/maps")
			map_node.call_deferred("add_child", map)
			
			get_parent().get_parent().queue_free()

