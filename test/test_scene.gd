extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var d:Dictionary = {"dict":"val"}
	print(d.erase("dict"))
	print(d)



