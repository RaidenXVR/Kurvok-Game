extends Node2D

signal tp_player(coor)

var map = preload("res://map/westEnterance.tscn").instantiate()
var can_change_map = true


func _ready():

	if GameData.current_map != null and GameData.current_map != "res://map/.tscn":
		map = load(GameData.current_map).instantiate()
	connect("tp_player", get_parent().get_node("Player").on_tp_player)
	add_child(map)

	
func _on_timer_timeout():
	for tm in get_children():
		if tm is TileMap:
			for area in tm.get_node("EntryPoint").get_children(true):
				if area is Area2D:
					area.monitoring = true
		if tm is Timer:
			remove_child(tm)
	

func _on_west_point_map_change(_map_name):
	
	var west_map = get_node(NodePath(_map_name)).west_map
	if west_map is Timer:
		return
	call_deferred("remove_child", get_node(NodePath(_map_name)))
	
	var map_scene = load(west_map).instantiate()
	for area in map_scene.get_node("EntryPoint").get_children(true):
		if area is Area2D:
			area.monitoring = false
	
	var timer = Timer.new()
	add_child(timer)
	timer.start(0.5)
	timer.connect("timeout", _on_timer_timeout)
	var tp_area = map_scene.find_child("eastPoint")
	
	if tp_area != null:
		var tp_coor = tp_area.position
		tp_coor.x -= 25*tp_area.scale.x
		emit_signal("tp_player", tp_coor)
		call_deferred("add_child", map_scene)


		
	

func _on_east_point_map_change(_map_name):
	var east_map=get_node(NodePath(_map_name)).east_map
	call_deferred("remove_child", get_child(0))
	
	var map_scene = load(east_map).instantiate()
	for area in map_scene.get_node("EntryPoint").get_children(true):
		if area is Area2D:
			area.monitoring = false

	var timer = Timer.new()
	add_child(timer)
	timer.start(0.5)
	timer.connect("timeout", _on_timer_timeout)
	
	var tp_area = map_scene.find_child("westPoint")
	if tp_area != null:
		var tp_coor = tp_area.position
		tp_coor.x += 20*tp_area.scale.x
		emit_signal("tp_player", tp_coor)
		call_deferred("add_child", map_scene)
	
