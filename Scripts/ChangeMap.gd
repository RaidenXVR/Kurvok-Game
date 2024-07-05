extends Node


var destinations = {
	"area1" : "res://world/world.tscn",
	"area2" : "res://world/world_2.tscn"
}

func change_map(area_name):
	var destination = destinations.get(area_name)
	if destination:
		get_tree().change_scene_to_file(destination)
