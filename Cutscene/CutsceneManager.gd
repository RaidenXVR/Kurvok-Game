extends Node

signal done_scene
signal cutscene_started
signal finished_doing_cutscene

var world_node : World
var player_node: Player
var dialogue_node: Dialogue
var trigger_node: CutsceneTrigger

var cutscenes_completed: Array[String] = []

var doing_cutscene: bool = false
var tween: Tween


func set_attributes(world:World):
	world_node = world
	player_node = world.get_node("Player")
	dialogue_node = world.get_node("CanvasLayer").get_node("Dialogue")


func do_cutscene(cutscene_name, init_area:CutsceneTrigger):
	var cutscenes: Cutscene = ResourceLoader.load("res://Cutscene/Cutscenes/{cutscene_name}.tres".format({"cutscene_name":cutscene_name})) as Cutscene

	if not cutscenes.check_quest_requirements():
		return
	
	cutscene_started.emit()

	trigger_node = init_area
	player_node.position = init_area.position
	player_node.set_process_input(false)
	doing_cutscene = true

	for cutscene in cutscenes.cutscene_to_do:
		if cutscene is Cutscene_MovePlayer:
			move_player(cutscene)
			await done_scene


		elif cutscene is Cutscene_MoveObject:
			move_object(cutscene)
			await done_scene


		elif cutscene is Cutscene_Dialogue:
			do_dialogue(cutscene)

	cutscenes_completed.append(cutscene_name)

	doing_cutscene = false
	player_node.set_process_input(true)

	finished_doing_cutscene.emit()

	cutscenes.set_main_quest()
	

func move_player(scene: Cutscene_MovePlayer):
	var target_positions = []
	var time_needs = []
	for i in range(len(scene.move_grid_amount)):
		var temp = scene.move_grid_amount[i] * scene.direction[i] *48
		var pos
		if i == 0: 
			pos = player_node.position + temp
		else:
			pos = target_positions[i-1] + temp
		var time_need:float = temp.length() / scene.speed 
		target_positions.append(pos)
		time_needs.append(time_need)
	
	var idx = 0
	for target in target_positions:
		tween = create_tween()
		tween.chain().tween_property(player_node,"position",target, time_needs[idx])
		tween.play()
		match scene.direction[idx]:
			Vector2(1,0):
				player_node.animation.play("walkRight")
			Vector2(-1,0):
				player_node.animation.play("walkLeft")
			Vector2(0,1):
				player_node.animation.play("walkDown")
			Vector2(0,-1):
				player_node.animation.play("walkUp")


		# player_node.animation.play()
		await tween.finished
		tween.stop()
		player_node.animation.stop()
		idx +=1
	# player_node.position = target_positions[-1]
	done_scene.emit()

func move_object(scene: Cutscene_MoveObject):
	var object_node: Node2D = world_node.get_node(scene.object_root).get_node(scene.object_name)
	object_node.position = trigger_node.position + (scene.start_pos_relative * 48)

	var target_positions = []
	var time_needs = []
	for i in range(len(scene.move_grid_amount)):
		var temp = scene.move_grid_amount[i] * scene.direction[i] *48
		var pos
		if i == 0:
			pos = object_node.position + temp
		else:
			pos = target_positions[i-1] + temp
		var time_need:float = temp.length() / scene.speed 
		target_positions.append(pos)
		time_needs.append(time_need)
	
	var idx = 0
	for target in target_positions:
		tween = create_tween()

		tween.chain().tween_property(object_node,"position",target, time_needs[idx])
		tween.play()
		match scene.direction[idx]:
			Vector2(1,0):
				object_node.animation_player.play("walkRight")
			Vector2(-1,0):
				object_node.animation_player.play("walkLeft")
			Vector2(0,1):
				object_node.animation_player.play("walkDown")
			Vector2(0,-1):
				object_node.animation_player.play("walkUp")

		await tween.finished
		tween.stop()

		object_node.animation_player.stop()
		idx +=1

	done_scene.emit()

func do_dialogue(scene: Cutscene_Dialogue):
	scene.init_vars()


	dialogue_node.starter(scene.lines,"", null, true, scene.actors)
	await dialogue_node.dialogue_finished
