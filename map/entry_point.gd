extends StaticBody2D

class_name EntryPoint

@export var map_destination:String
@export var entry_point_destination:String
enum OutOffset {OFFSET_UP, OFFSET_DOWN, OFFSET_LEFT, OFFSET_RIGHT}
@export var self_out_offset: OutOffset
@export var is_deactivated: bool
@export var activation_requirement: Array[String]


func change_map(player_body:Player):
	for r in activation_requirement:
		if not (QuestManager.check_quest_in_complete(r) or QuestManager.current_main_quest.check_quest_in_complete(r)):
			is_deactivated = true
			break
		is_deactivated = false
	if is_deactivated:
		var scene = load("res://Cutscene/Cutscenes/AreaDeactivate.tres").duplicate(true) as Cutscene
		var dir = -player_body.moveDir if player_body.moveDir != Vector2.ZERO else player_body.look_dir.target_position/20
		scene.cutscene_to_do[0].direction[0] = dir
		scene.initial_position = player_body.position
		CutsceneManager.do_cutscene(scene)
		await CutsceneManager.finished_doing_cutscene
		return
	var load_map = load("res://map/"+map_destination+".tscn")
	var map: TileMap
	if load_map:
		map = load_map.instantiate()
		var entry_point = map.get_node("EntryPoints/"+ entry_point_destination) as EntryPoint
		if entry_point:
			player_body.set_process_input(false)
			player_body.set_physics_process(false)
			match entry_point.self_out_offset:
				0:
					player_body.position = Vector2(entry_point.position.x, entry_point.position.y - (40* entry_point.scale.y))
				1:
					player_body.position = Vector2(entry_point.position.x, entry_point.position.y+(60* entry_point.scale.y))
				2:
					player_body.position = Vector2(entry_point.position.x-(60* entry_point.scale.x), entry_point.position.y)
				3:
					player_body.position = Vector2(entry_point.position.x+(60* entry_point.scale.x), entry_point.position.y)
			get_node("/root/World/maps").call_deferred("add_child", map)
			get_parent().get_parent().queue_free()
			player_body.set_process_input(true)
			player_body.set_physics_process(true)
