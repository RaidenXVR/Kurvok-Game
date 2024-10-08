extends Node

var audio_players: Dictionary ={}
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var music = AudioStreamPlayer.new()
	var sfx = AudioStreamPlayer.new()
	audio_players["sfx"] = sfx
	sfx.autoplay = false
	
	audio_players["main_music"] = music
	music.stream = load("res://Audio/bgmusic.WAV")
	music.autoplay = true
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	music.volume_db = lerp(-40.0,0.0, 80.0/100.0)
	sfx.volume_db = 0.0
	
	add_child(music)
	add_child(sfx)

func new_audio_player(key: String, stream_sound: AudioStream) -> AudioStreamPlayer:
	var sound = AudioStreamPlayer.new()
	sound.stream = stream_sound
	audio_players[key] = sound
	return sound
	
	
