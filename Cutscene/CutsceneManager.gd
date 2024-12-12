extends Node

signal done_scene
signal cutscene_started
signal finished_doing_cutscene

var world_node : World
var player_node: Player
var dialogue_node: Dialogue
var trigger_node_position: Vector2

var cutscenes_completed: Array[String] = []

var doing_cutscene: bool = false
var tween: Tween

var dialogue_style

func set_attributes(world:World):
	world_node = world
	player_node = world.get_node("Player")
	dialogue_node = world.get_node("CanvasLayer").get_node("Dialogue")


func do_cutscene(cutscene_name, init_area:CutsceneTrigger = null):
	var cutscenes: Cutscene
	if cutscene_name is Cutscene:
		cutscenes = cutscene_name
	else:
		cutscenes = ResourceLoader.load("res://Cutscene/Cutscenes/{cutscene_name}.tres".format({"cutscene_name":cutscene_name})) as Cutscene

	if not cutscenes.check_quest_requirements():
		return
	
	cutscene_started.emit()
	GameData.filter(Color.BLACK, 0.1, 0.1, 1)
	await GameData.filter_finished
	AudioManager.pause_music()
	
	if init_area:
		trigger_node_position = init_area.position
		player_node.position = init_area.position
	elif not init_area and cutscenes.trigger_node_path:
		var trigger_node = get_node("/root/World/maps").get_child(0).get_node(cutscenes.trigger_node_path)
		trigger_node_position = trigger_node.position
	else :
		trigger_node_position = cutscenes.initial_position
		
		pass
	player_node.set_process_input(false)
	doing_cutscene = true

	for cutscene in cutscenes.cutscene_to_do:
		if cutscene is Cutscene_MovePlayer:
			move_player(cutscene)
			if not cutscene.parallel_with_next:
				await done_scene


		elif cutscene is Cutscene_MoveObject:
			move_object(cutscene)
			if not cutscene.parallel_with_next:
				await done_scene


		elif cutscene is Cutscene_Dialogue:
			do_dialogue(cutscene)
			await dialogue_node.dialogue_finished
		
		elif cutscene is Cutscene_MovieNarator:
			do_movie(cutscene)
			await dialogue_node.dialogue_finished
			var movie_player: VideoStreamPlayer = get_node("/root/World/CanvasLayer/Movie")
			for child in dialogue_node.get_children():
				if not child is Timer:
					child.visible = true
				if child.name == "Panel":
					child.add_theme_stylebox_override("panel", dialogue_style) 
					child.position.y += 200
			movie_player.stop()
			movie_player.stream = null
		
		elif cutscene is Cutscene_QuestStarted:
			do_quest_started(cutscene)
			await dialogue_node.dialogue_finished

		
		elif cutscene is Cutscene_Spacer:
			var timer = Timer.new()
			timer.one_shot = true
			add_child(timer)
			timer.start(cutscene.time)
			await timer.timeout
			remove_child(timer)
		
		elif cutscene is Cutscene_PlayAnimation:
			do_play_anim(cutscene)
			if not cutscene.parallel_with_next:
				await done_scene
		elif cutscene is Cutscene_CGDialogue:
			do_cg_dialogue(cutscene)
			await dialogue_node.dialogue_finished


	cutscenes_completed.append(cutscene_name)

	doing_cutscene = false
	player_node.set_process_input(true)
	player_node.animation.play("RESET")

	finished_doing_cutscene.emit()

	cutscenes.set_main_quest()

	AudioManager.resume_music()
		


	GameData.filter(Color.BLACK, 0.1, 0.1, 0.5)
	

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
		if target == player_node.position:
			time_needs[idx] = 1
		tween.chain().tween_property(player_node,"position",target, time_needs[idx])
		tween.play()
		if not target == player_node.position:
			match scene.direction[idx]:
				Vector2(1,0):
					player_node.animation.play("walkRight")
				Vector2(-1,0):
					player_node.animation.play("walkLeft")
				Vector2(0,1):
					player_node.animation.play("walkDown")
				Vector2(0,-1):
					player_node.animation.play("walkUp")
		else:
			match scene.direction[idx]:
				Vector2(1,0):
					player_node.animation.play("idleRight")
				Vector2(-1,0):
					player_node.animation.play("idleLeft")
				Vector2(0,1):
					player_node.animation.play("idleDown")
				Vector2(0,-1):
					player_node.animation.play("idleUp")

		# player_node.animation.play()
		await tween.finished
		tween.stop()
		player_node.animation.stop()
		tween.kill()
		idx +=1
	# player_node.position = target_positions[-1]
	done_scene.emit()

func move_object(scene: Cutscene_MoveObject):
	var object_node: Node2D = world_node.get_node(scene.object_root).get_node(scene.object_name)
	object_node.position = trigger_node_position + (scene.start_pos_relative * 48)

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
	
func do_quest_started(scene: Cutscene_QuestStarted):
	dialogue_node.get_node("NameLabel").position = Vector2(380, 155)
	dialogue_node.get_node("Panel").position = Vector2(0,220)
	AudioManager.audio_players["sfx"].stream = load("res://Audio/Start_Game.wav")
	get_node("/root/World").do_pop_up("Quest Started")	
	AudioManager.audio_players["sfx"].play()
	await AudioManager.audio_players["sfx"].finished
	
	dialogue_node.starter([{"char":scene.quest_name, "dialogue":scene.description}], "", null,true, [{scene.quest_name:"male"}])
	await dialogue_node.dialogue_finished
	dialogue_node.get_node("NameLabel").position = Vector2(120, 420)
	dialogue_node.get_node("Panel").position = Vector2(0,440)
	
	pass

	
func do_movie(scene: Cutscene_MovieNarator):
	AudioManager.audio_players["main_music"].stop()
	if not scene.lines:
		var movie_player: VideoStreamPlayer = get_node("/root/World/CanvasLayer/Movie")
		movie_player.stream = scene.movie
		movie_player.play()
	
	else:
		var movie_player: VideoStreamPlayer = get_node("/root/World/CanvasLayer/Movie")
		movie_player.stream = scene.movie
		
		dialogue_node = get_node("/root/World/CanvasLayer/Dialogue")
		for child in dialogue_node.get_children():
			if child.name != "Panel":
				if not child is Timer:
					child.visible = false
			else:
				dialogue_style = child.get_theme_stylebox("panel")
				child.add_theme_stylebox_override("panel", StyleBoxEmpty.new()) 
				child.position.y -= 200
				
		dialogue_node.visible = true
		var dia = []
		for line in scene.lines:
			dia.append({"char":"", "dialogue":line})
		movie_player.play()
		dialogue_node.starter(dia, "", null, true)
		
func do_play_anim(scene:Cutscene_PlayAnimation):
	if scene.type == scene.ObjectAnimType.NPC_OBJ:
		var object:NPC = get_node("/root/World/maps").get_child(0).get_node(scene.object)
		object.get_node("AnimationPlayer").play(scene.animation_to_play)
		await object.get_node("AnimationPlayer").animation_finished
		done_scene.emit()
	elif scene.type == scene.ObjectAnimType.PLAYER:
		var object: Player = get_node("/root/World/Player")
		object.animation.play(scene.animation_to_play)
		if scene.secondary_animation_to_play:
			object.vfx_node.scale = scene.vfx_sprite_scale
			object.vfx_node.visible = true
			object.vfx_node.play(scene.secondary_animation_to_play)
		await object.animation.animation_finished
		done_scene.emit()

func do_cg_dialogue(scene: Cutscene_CGDialogue):
	var cg_node: TextureRect = get_node("/root/World/CanvasLayer/CG")
	cg_node.texture = scene.cg_background
	
	scene.init_vars()
	dialogue_node.get_node("TextureRect").visible = false
	dialogue_node.get_node("LeftPortrait").visible = false
	dialogue_node.get_node("RightPortrait").visible = false
	
	dialogue_node.starter(scene.lines,"", null, true, scene.actors)
	
	await dialogue_node.dialogue_finished
	cg_node.texture = null
	dialogue_node.get_node("TextureRect").visible = true
	dialogue_node.get_node("LeftPortrait").visible = true
	dialogue_node.get_node("RightPortrait").visible = true
	

