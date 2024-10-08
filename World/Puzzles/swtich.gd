extends StaticBody2D

class_name Switch

@export var switch_id: String
@export var state: bool = false
@export var texture: Texture2D


func _ready():
	$Sprite2D.texture = texture
	state = GameData.switches.get(switch_id, state)

func change_state():
	state = !state
	GameData.switches[switch_id] = state
	var sound:AudioStream
	if state:
		$Sprite2D.frame = 0
		sound = load("res://Audio/switch_close.wav")
	else:
		$Sprite2D.frame = 1
		sound = load("res://Audio/switch_open.wav")
	AudioManager.audio_players["sfx"].stream = sound
	AudioManager.audio_players["sfx"].play()
	#TODO: change sprite
	GameData.switch_state_change.emit()
	

