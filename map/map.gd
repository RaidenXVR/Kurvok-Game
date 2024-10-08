extends TileMap

@export var west_map: String
@export var east_map: String
@export var north_map: String
@export var south_map: String
@export var music_path:String

func _ready():
	AudioManager.audio_players["main_music"].stop()
	if music_path:
		var music = load(music_path)
		AudioManager.audio_players["main_music"].stream = music
		AudioManager.audio_players["main_music"].play()
	
	GameData.tile_size = rendering_quadrant_size
	
	
	var switches = get_node("Switches")
	if switches:
		for switch: Switch in switches.get_children():
			GameData.switches[switch.switch_id] = switch.state
			

func _on_west_point_body_entered(body:Node2D):
	if body is Player:
		body.set_physics_process(false)
		print("map west point entered")
		var load_map = "res://map/"+west_map+".tscn"
		var map = load(load_map).instantiate()
		var tp_area = map.get_node("EntryPoint/eastPoint")

		if tp_area != null:
			var player_node = get_node("/root/World/Player") as Player
			var tp_coor = tp_area.position
			tp_coor.x -= 25*tp_area.scale.x
			player_node.position = tp_coor
			get_parent().call_deferred("add_child", map)
			self.queue_free()
		body.set_physics_process(true)
		



func _on_east_point_body_entered(body:Node2D):
	if body is Player:
		body.set_physics_process(false)
		var load_map = "res://map/"+east_map+".tscn"
		var map = load(load_map).instantiate()
		var tp_area = map.get_node("EntryPoint/westPoint")

		if tp_area != null:
			var player_node = get_node("/root/World/Player") as Player
			var tp_coor = tp_area.position
			tp_coor.x += 25*tp_area.scale.x
			player_node.position = tp_coor
			get_parent().call_deferred("add_child", map)
			self.queue_free()
		body.set_physics_process(true)


func _on_north_point_body_entered(body:Node2D):
	if body is Player:
		body.set_physics_process(false)
		var load_map = "res://map/"+north_map+".tscn"
		var map = load(load_map).instantiate()
		var tp_area = map.get_node("EntryPoint/southPoint")

		if tp_area != null:
			var player_node = get_node("/root/World/Player") as Player
			var tp_coor = tp_area.position
			tp_coor.y -= 25*tp_area.scale.y
			player_node.position = tp_coor
			get_parent().call_deferred("add_child", map)
			self.queue_free()
		body.set_physics_process(true)

func _on_south_point_body_entered(body:Node2D):
	if body is Player:
		print("called south point")
		body.set_physics_process(false)
		var load_map = "res://map/"+south_map+".tscn"
		var map = load(load_map).instantiate()
		var tp_area = map.get_node("EntryPoint/northPoint")

		if tp_area != null:
			var player_node = get_node("/root/World/Player") as Player
			var tp_coor = tp_area.position
			tp_coor.y += 50*tp_area.scale.y
			player_node.position = tp_coor
			get_parent().call_deferred("add_child", map)
			self.queue_free()
		body.set_physics_process(true)
