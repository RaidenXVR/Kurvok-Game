extends CharacterBody2D

class_name NPC



@export var texture_img:Texture2D
@export var isNPCCanMove:bool = true
@export var facing_dir: Vector2
@export var npc_quest: Array[Quest]
@export var is_main_npc: bool
@onready var sprite_npc = $Sprite2D
@onready var animation_player = $AnimationPlayer

var timer = Timer.new()

var distance_must_travel = 48
var initial_pos
var speed:int = 35
var is_moving: bool = false
var tileSize = 48
var target_coor:Vector2
var colliding:bool = false
var last_dir: String = "Down"
var last_pos


func _ready():
	sprite_npc.texture = texture_img
	sprite_npc.scale = Vector2(1.5,1.5)
	if isNPCCanMove:
		add_child(timer)
		timer.connect("timeout",_on_timer_timeout)
		timer.one_shot = true
		timer.start(2)
	else:
		set_physics_process(false)
	CutsceneManager.cutscene_started.connect(_on_started_cutscene_signal)
	CutsceneManager.finished_doing_cutscene.connect(_on_finished_cutscene_signal)
	match facing_dir:
		Vector2(1,0):
			animation_player.play("idleRight")
		Vector2(-1,0):
			animation_player.play("idleLeft")
		Vector2(0,-1):
			animation_player.play("idleUp")
		Vector2(0,1):
			animation_player.play("idleDown")

	animation_player.stop()


func _physics_process(_delta):
	if isNPCCanMove and not CutsceneManager.doing_cutscene:
		if is_moving:
			velocity = target_coor.normalized() *speed
			colliding = move_and_slide()
			if last_pos == position and timer.is_stopped():
				timer.start(2)
				pass
			if (position.distance_to(initial_pos))>distance_must_travel or colliding:
				last_pos = position
				animation_player.play("idle"+last_dir)

				is_moving = false
				timer.start(2)

	
	

func random_desti():
	var rand_dis = randi_range(0,5)
	var rand = randi_range(0,1)
	var rand_y = 0
	var rand_x = 0
	if rand == 0:
		rand_y = randi_range(-3,3)
		if rand_y >0 :
			animation_player.play("walkDown")
			last_dir = "Down"
		elif rand_y<0:
			animation_player.play("walkUp")
			last_dir="Up"
		else:
			animation_player.play("idle"+last_dir)
	else:
		rand_x = randi_range(-3,3)
		if rand_x>0:
			animation_player.play("walkRight")
			last_dir = "Right"
		elif rand_x < 0:
			animation_player.play("walkLeft")
			last_dir="Left"
		else:
			animation_player.play("idle"+last_dir)
	distance_must_travel = 48* rand_dis
	target_coor = Vector2(rand_x*tileSize,rand_y*tileSize)


func _on_timer_timeout():
	initial_pos = position
	random_desti()
	is_moving = true

func take_quest_items(item_type: String,item_id:int, amount:int):
	if GameData.rem_item(item_type, item_id,amount):
		return true #quest successful
	else:
		return false #quests unsuccessful, not enough item
	

func talk():
	var file_diag = FileAccess.get_file_as_string("res://NPC/npc_dialogue.json")
	var dialogs = JSON.parse_string(file_diag)
	var dialogue_node = get_tree().root.get_node("World").get_node("CanvasLayer").find_child("Dialogue")
	var dialogue = dialogs[self.name]
	var dialog
	if len(npc_quest) != 0:
		if (not QuestManager.set_available_quests(npc_quest[0])) and QuestManager.check_where_quest(npc_quest[0].quest_name) == 2:
			npc_quest.remove_at(0)
			if len(npc_quest) != 0:  # Add this check to prevent infinite recursion
				talk()
			return

		var where = QuestManager.check_where_quest(npc_quest[0].quest_name)
		match where:
			0:
				var temp_diag = dialogue[npc_quest[0].quest_name]
				dialog = temp_diag["pre-quest"]
				dialogue_node.starter(dialog,self.name, npc_quest[0])

			1:
				if QuestManager.check_quest(npc_quest[0]):
					dialog = dialogue[npc_quest[0].quest_name]["post-quest"]
					QuestManager.set_complete_quests(npc_quest[0])
					npc_quest.remove_at(0)
					dialogue_node.starter(dialog,self.name)
				else:
					dialog = dialogue[npc_quest[0].quest_name]["in-quest"]
					dialogue_node.starter(dialog,self.name)
			_:
				dialog = dialogue["non-quest-dialogue"]
				dialogue_node.starter(dialog,self.name)
				# QuestManager.check_target(self.name, 1)

	elif is_main_npc:
		var quests = QuestManager.current_main_quest.get_quest_by_giver(name) as Array[Quest]
		if quests:
			for q in quests:
				QuestManager.current_main_quest.check_quest(q)


	else:
		dialog = dialogue["non-quest-dialogue"]
		dialogue_node.starter(dialog,self.name)
		# QuestManager.check_target(self.name, 1)
	
	if QuestManager.check_talk(name) == 1:
		var quests_for_npc: Array[Quest] = QuestManager.get_talk_quest(name)
		if quests_for_npc:
			for q in quests_for_npc:
				dialog = dialogue[q.quest_name]
				dialogue_node.starter(dialog, name)
				QuestManager.check_talk(name,true)
	# QuestManager.check_talk(name)
	if not isNPCCanMove:
		match facing_dir:
			Vector2(1,0):
				animation_player.play("idleRight")
			Vector2(-1,0):
				animation_player.play("idleLeft")
			Vector2(0,-1):
				animation_player.play("idleUp")
			Vector2(0,1):
				animation_player.play("idleDown")
				


func _on_started_cutscene_signal():
	set_physics_process(false)

func _on_finished_cutscene_signal():
	set_physics_process(true)
