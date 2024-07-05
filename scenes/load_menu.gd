extends Control




func _on_save_0_pressed():
	GameData.load_game(0)
	get_tree().change_scene_to_file("res://World/World.tscn")


func _on_save_1_pressed():
	GameData.load_game(1)
	get_tree().change_scene_to_file("res://World/World.tscn")


func _on_save_2_pressed():
	GameData.load_game(2)
	get_tree().change_scene_to_file("res://World/World.tscn")
