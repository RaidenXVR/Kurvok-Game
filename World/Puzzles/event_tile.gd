extends StaticBody2D

class_name EventTile

enum EventType {EVENT_SWTICH, EVENT_TILE_PATTERN}

@export var requirements: Dictionary
@export var event_type: EventType
var closed: bool = true
# Called when the node enters the scene tree for the first time.
func _ready():
	
	if event_type == EventType.EVENT_SWTICH:
		GameData.switch_state_change.connect(_on_switch_state_change)
		_on_switch_state_change()
		
	elif event_type == EventType.EVENT_TILE_PATTERN:
		GameData.tile_pattern_completed.connect(func(x): _on_tile_pattern_completed(x))	
		_on_tile_pattern_completed()

func _on_switch_state_change():
	for req in requirements.keys():
		if GameData.switches.get(req, null) != requirements[req]:
			closed = true
			break
		else:
			closed = false
	
	if not closed:
		$CollisionShape2D.set_deferred("disabled", true)
		$Sprite2D.frame=1
	else:
		$CollisionShape2D.set_deferred("disabled", false)
		$Sprite2D.frame=0

func _on_tile_pattern_completed(pattern_group = null):
	if pattern_group == null:
		for req in requirements.keys():
			print(req)
			if GameData.tile_pattern_group.get(req, null) != requirements[req]:
				closed = true
				break
			else:
				closed = false
	else:
		closed = false
		
	
	if not closed:
		$CollisionShape2D.set_deferred("disabled", true)
		$Sprite2D.frame=1
	else:
		$CollisionShape2D.set_deferred("disabled", false)
		$Sprite2D.frame=0

	


	
