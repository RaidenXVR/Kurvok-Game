extends Node

var audio_players: Dictionary ={}
var audio_time_paused
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var music = AudioStreamPlayer.new()
	var sfx = AudioStreamPlayer.new()
	audio_players["sfx"] = sfx
	sfx.autoplay = false
	
	
	
	audio_players["main_music"] = music
	music.stream = load("res://Audio/OP.wav")
	music.autoplay = true
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	music.volume_db = lerp(-40.0,0.0, 80.0/100.0)
	sfx.volume_db = 0.0
	
	add_child(music)
	add_child(sfx)
	get_tree().tree_changed.connect(new_scene_entered)

func new_scene_entered():
	if get_tree():
		var buttons: Array = get_tree().get_nodes_in_group("Button")
		for butt:Button in buttons:
			if not butt.is_connected("focus_entered", _on_any_button_hover):
				butt.connect("focus_entered", _on_any_button_hover)
				butt.connect("mouse_entered", _on_any_button_hover)
				#butt.connect("pressed", _on_any_button_pressed)
				butt.connect("button_down", _on_any_button_pressed)

func new_audio_player(key: String, stream_sound: AudioStream) -> AudioStreamPlayer:
	var sound = AudioStreamPlayer.new()
	sound.stream = stream_sound
	audio_players[key] = sound
	return sound
	

func _on_any_button_hover():
	audio_players["sfx"].stream = load("res://Audio/Hover.wav")
	audio_players["sfx"].play()

func _on_any_button_pressed():
	audio_players["sfx"].stream = load("res://Audio/Click.wav")
	audio_players["sfx"].play()
	
func pause_music():
	audio_players["main_music"].stop()
	audio_time_paused = audio_players["main_music"].get_playback_position()

func resume_music():
	audio_players["main_music"].play(audio_time_paused)
