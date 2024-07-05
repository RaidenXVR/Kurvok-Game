extends CharacterBody2D

class_name NPC

@export var texture_img:Texture2D
@export var isNPCCanMove:bool = true
@export var npc_quest: String
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

func _physics_process(_delta):
	if isNPCCanMove:
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
	# print(target_coor)


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
	if npc_quest != "":
		QuestManager.set_available_quests(npc_quest)
		var where = QuestManager.check_where_quest(npc_quest)
		match where:
			0:
				var temp_diag = dialogue["quest-dialog"]
				dialog = temp_diag["pre-quest"]
				dialogue_node.starter(dialog,self.name, npc_quest)

			1:
				if QuestManager.check_quest(npc_quest):
					dialog = dialogue["quest-dialog"]["post-quest"]
					QuestManager.set_complete_quests(npc_quest)
					dialogue_node.starter(dialog,self.name)
				else:
					dialog = dialogue["quest-dialog"]["in-quest"]
					dialogue_node.starter(dialog,self.name)
			_:
				dialog = dialogue["non-quest-dialog"]
				dialogue_node.starter(dialog,self.name)
				QuestManager.check_target(self.name, 1)


	else:
		dialog = dialogue["non-quest-dialog"]
		dialogue_node.starter(dialog,self.name)
		print("else")
		QuestManager.check_target(self.name, 1)