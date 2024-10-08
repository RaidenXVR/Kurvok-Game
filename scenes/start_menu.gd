extends Control





func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/load_menu.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_option_pressed():
	var option = $MarginContainer/VBoxContainer/Option/OptionContainer
	$MarginContainer/VBoxContainer/Start.visible = false
	$MarginContainer/VBoxContainer/Quit.visible = false
	option.visible = true


func _on_option_container_hidden():
	$MarginContainer/VBoxContainer/Start.visible = true
	$MarginContainer/VBoxContainer/Quit.visible = true

func _input(event):
	if event.is_action_pressed("menu"):
		$MarginContainer/VBoxContainer/Option/OptionContainer.visible = false


func _on_master_slider_value_changed(value):
	var db = lerp(-40.0,0.0, value/100.0)
	AudioServer.set_bus_volume_db(0, db)


func _on_music_slider_value_changed(value):
	var db = lerp(-40.0,0.0, value/100.0)
	var music: AudioStreamPlayer = AudioManager.audio_players["main_music"]
	music.volume_db = db


func _on_sfx_slider_value_changed(value):
	var db = lerp(-40.0,0.0, value/100.0)
	var sfx: AudioStreamPlayer = AudioManager.audio_players["sfx"]
	sfx.volume_db = db
