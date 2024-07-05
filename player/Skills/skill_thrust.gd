extends Node2D



@onready var skilling_timer = $SkillingTimer
@onready var skill_cd = $SkillTimer
@onready var attack_box = $AttackBox
@onready var attack_box_shape = $AttackBox/CollisionShape2D
@onready var attack_box_polygon = $AttackBox/CollisionPolygon2D
@onready var skill_1_cd_gui = get_node("/root/World/CanvasLayer/Skill1CD")

var player:Player
var can_skill = true
var is_skilling = false
var knockPower = 250
var skill_state = SkillTree.Skill_Tree.LIGHTNING
var drag_force = 0
var vel

var circle_shape = CircleShape2D.new()
var capsule_shape = CapsuleShape2D.new()

var cd_gui_0 = preload("res://asset/CD_frame0.png")
var cd_gui_1 = preload("res://asset/CD_frame1.png")


func _ready():
	if GameData.current_skill_equipped == 1:
		skill_1_cd_gui.texture_over = cd_gui_1
	else:
		skill_1_cd_gui.texture_over = cd_gui_0

func _process(_delta):
	if !can_skill:
		skill_1_cd_gui.value = snapped(skill_cd.time_left,0.1)
	if is_skilling:
		player.velocity = vel - (vel*drag_force)
		drag_force += 0.04
		player.move_and_slide()



func cast_skill(state:SkillTree.Skill_Tree, lastAnimDir:String= "Down"):
	player = get_node("/root/World/Player") 
	if state == SkillTree.Skill_Tree.LIGHTNING:
		lightning_thrust(lastAnimDir)
	elif state == SkillTree.Skill_Tree.WIND:
		aeroblast(lastAnimDir)
	elif state == SkillTree.Skill_Tree.WATER:
		aqua_lance(lastAnimDir)
	

func lightning_thrust(lastAnimDir): #Movement/Basic
	if !can_skill: return
	drag_force = 0
	is_skilling = true
	can_skill = false
	player.animation.stop()
	attack_box_polygon.polygon = [Vector2(25,0),Vector2(0,-60), Vector2(-25,0)]
	match lastAnimDir:
		"Down":	
			player.velocity = Vector2(0,1) * knockPower *5
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,2)
			attack_box_polygon.position = Vector2(0,-15)
			attack_box_polygon.rotation_degrees = 180

		"Up": 
			player.velocity  = Vector2(0,-1) * knockPower *5
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,0)
			attack_box_polygon.position = Vector2(0,-25)
			attack_box_polygon.rotation_degrees = 0

		"Left": 
			player.velocity = Vector2(-1,0)*knockPower *5
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,1)
			attack_box_polygon.position = Vector2(0,-15)
			attack_box_polygon.rotation_degrees = -90


		"Right": 
			player.velocity = Vector2(1,0)* knockPower*5
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,3)
			attack_box_polygon.position =  Vector2(0,-15)
			attack_box_polygon.rotation_degrees = 90

	vel = player.velocity
	attack_box.monitoring = true
	player.collision_mask = 2
	player.collision_layer = 2
	player.move_and_slide()
	attack_box_shape.disabled = true
	attack_box_polygon.disabled = false
	skill_1_cd_gui.max_value = 3.0
	skilling_timer.start(0.1)
	skill_cd.start(3)
	skill_1_cd_gui.texture_over = cd_gui_0
	player.doing_skill_1 = true


func aeroblast(lastAnimDir):
	if !can_skill: return
	drag_force = 0
	is_skilling = true
	can_skill = false
	player.animation.stop()
	attack_box_shape.shape = circle_shape
	attack_box_shape.shape.radius = 50
	match lastAnimDir:
		"Down":	
			player.velocity = Vector2(0,-1) * knockPower *3
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,2)
			attack_box_shape.position = Vector2(0,15)
			attack_box_shape.rotation_degrees = 90

		"Up": 
			player.velocity  = Vector2(0,1) * knockPower *3
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,0)
			attack_box_shape.position = Vector2(0,-60)
			attack_box_shape.rotation_degrees = 90

		"Left": 
			player.velocity = Vector2(1,0)*knockPower *3
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,1)
			attack_box_shape.position = Vector2(-35,-20)
			attack_box_shape.rotation_degrees = 0


		"Right": 
			player.velocity = Vector2(-1,0)* knockPower *3
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,3)
			attack_box_shape.position =  Vector2(35,-20)
			attack_box_shape.rotation_degrees = 0

	vel = player.velocity
	attack_box.monitoring = true
	attack_box_shape.disabled = false
	attack_box_polygon.disabled = true
	skill_1_cd_gui.max_value = 3.0
	skilling_timer.start(0.2)
	skill_cd.start(3)
	skill_1_cd_gui.texture_over = cd_gui_0
	player.doing_skill_1 = true


func aqua_lance(lastAnimDir):
	if !can_skill: return
	drag_force = 0
	is_skilling = true
	can_skill = false
	player.animation.stop()
	var polygon_points = [Vector2(10,0),Vector2(0,-120), Vector2(-10,0)]
	match lastAnimDir:
		"Down":	
			player.velocity = Vector2(0,1) * knockPower *2
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,2)
			attack_box_polygon.position = Vector2(0,-15)
			attack_box_polygon.rotation_degrees = 180

		"Up": 
			player.velocity  = Vector2(0,-1) * knockPower*2
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,0)
			attack_box_polygon.position = Vector2(0,-15)
			attack_box_polygon.rotation_degrees = 0

		"Left": 
			player.velocity = Vector2(-1,0)*knockPower *2
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,1)
			attack_box_polygon.position = Vector2(0,-15)
			attack_box_polygon.rotation_degrees = -90


		"Right": 
			player.velocity = Vector2(1,0)* knockPower *2
			player.player_sprite.visible = false
			player.player_attack_sprite.visible = true
			player.player_attack_sprite.frame_coords = Vector2(4,3)
			attack_box_polygon.position =  Vector2(0,-15)
			attack_box_polygon.rotation_degrees = 90

	vel = player.velocity
	attack_box.monitoring = true
	attack_box_polygon.disabled = false
	attack_box_polygon.polygon = polygon_points
	attack_box_shape.disabled = true
	skill_1_cd_gui.max_value = 3.0
	skilling_timer.start(0.2)
	skill_cd.start(3)
	skill_1_cd_gui.texture_over = cd_gui_0
	player.doing_skill_1 = true


func _on_skilling_timer_timeout():
	is_skilling = false
	player.doing_skill_1 = false
	player.player_sprite.visible = true
	player.player_attack_sprite.visible = false
	attack_box_shape.shape = circle_shape
	attack_box_shape.shape.radius = 20
	attack_box_shape.position = Vector2(0,0)
	attack_box_polygon.position = Vector2(0,0)
	attack_box_polygon.disabled = true
	attack_box_shape.rotation_degrees = 0
	attack_box.monitoring = false

	player.collision_mask = 11
	player.collision_layer = 11
	attack_box_shape.disabled = true


func _on_skill_timer_timeout():
	can_skill = true
	skill_1_cd_gui.texture_over = cd_gui_1

func _on_attack_box_area_entered(area:Area2D):
	if area.get_parent() is Enemy:
		var bonus_atk = SkillTree.get_properties(skill_state)["bonus_atk"]
		area.get_parent().damaged(player.stats.att + bonus_atk)

func _on_attack_box_body_entered(body:Node2D):
	if body is Projectile and body.from_enemy:
		body.velocity = Vector2.ZERO
		body.queue_free()



func set_equip(is_equipped:bool):
	if is_equipped:
		skill_1_cd_gui.texture_over = cd_gui_1
	else:
		skill_1_cd_gui.texture_over = cd_gui_0
