extends Control

var progress = []
var world
var loading_status = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	AudioManager.audio_players["main_music"].stop()
	world = "res://World/World.tscn"
	ResourceLoader.load_threaded_request(world)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	loading_status = ResourceLoader.load_threaded_get_status(world, progress)
	$Label.text = str(floor(progress[0]*100))+"%"
	if loading_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(world)
		get_tree().change_scene_to_packed(new_scene)
