extends Control




func _on_save_0_pressed():
	GameData.load_game(0)
	var world = load("res://scenes/loading_scene.tscn")
	get_tree().change_scene_to_packed(world)



func _on_save_1_pressed():
	GameData.load_game(1)
	var world = load("res://scenes/loading_scene.tscn")
	get_tree().change_scene_to_packed(world)


func _on_save_2_pressed():
	GameData.load_game(2)
	var world = load("res://scenes/loading_scene.tscn")
	get_tree().change_scene_to_packed(world)

func _input(event):
	if event.is_action_pressed("menu"):
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
