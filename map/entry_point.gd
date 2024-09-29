extends StaticBody2D

class_name EntryPoint

@export var map_destination:String
@export var entry_point_destination:String
enum OutOffset {OFFSET_UP, OFFSET_DOWN, OFFSET_LEFT, OFFSET_RIGHT}
@export var self_out_offset: OutOffset


func change_map(player_body:Player):
	var load_map = load("res://map/"+map_destination+".tscn")
	var map: TileMap
	if load_map:
		map = load_map.instantiate()
		var entry_point = map.get_node("EntryPoints/"+ entry_point_destination) as EntryPoint
		if entry_point:
			player_body.set_process_input(false)
			player_body.set_physics_process(false)
			match entry_point.self_out_offset:
				0:
					player_body.position = Vector2(entry_point.position.x, entry_point.position.y - (40* entry_point.scale.y))
				1:
					player_body.position = Vector2(entry_point.position.x, entry_point.position.y+(60* entry_point.scale.y))
				2:
					player_body.position = Vector2(entry_point.position.x-(60* entry_point.scale.x), entry_point.position.y)
				3:
					player_body.position = Vector2(entry_point.position.x+(60* entry_point.scale.x), entry_point.position.y)
			get_node("/root/World/maps").call_deferred("add_child", map)
			get_parent().get_parent().queue_free()
			player_body.set_process_input(true)
			player_body.set_physics_process(true)
