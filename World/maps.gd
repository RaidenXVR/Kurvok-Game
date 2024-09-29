extends Node2D

signal tp_player(coor)


var map
var can_change_map = true


func _ready():

	if GameData.current_map != null:
		map = load(GameData.current_map).instantiate()

	add_child(map)

	
