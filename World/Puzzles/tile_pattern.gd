extends Area2D

@export var tile_pattern_id: String
@export var tile_pattern_group: String
@export var previous_pattern_id:String
@export var is_end_point:bool
@export var start_point:Vector2

func _ready():
	GameData.tile_pattern_completed.connect(func(x): _on_tile_pattern_completed(x))


func _on_body_entered(body):
	if body is Player:
		if is_end_point and GameData.current_tile_pattern_id == previous_pattern_id:
			GameData.current_tile_pattern_id = ""
			GameData.tile_pattern_completed.emit(tile_pattern_group)
			GameData.tile_pattern_group[tile_pattern_group] = true
			return
		if GameData.current_tile_pattern_id == previous_pattern_id:
			GameData.current_tile_pattern_id = tile_pattern_id

				
		else:
			GameData.current_tile_pattern_id = ""
			GameData.filter(Color.WHITE, 0.3, 0.3, 0.5)
			await GameData.do_tp
			body.position = start_point
	
			
func _on_tile_pattern_completed(tile_group):
	if tile_group == tile_pattern_group:
		set_deferred("monitoring", false)

