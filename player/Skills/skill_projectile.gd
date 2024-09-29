extends Node2D


@onready var skilling_timer = $SkillingTimer
@onready var skill_cd = $SkillTimer
@onready var skill_2_cd_gui = get_node("/root/World/CanvasLayer/Skill2CD")

var player:Player
var can_skill = true
var is_skilling = false
var knockPower = 300
var skill_state

var cd_gui_0 = preload("res://asset/CD_frame0.png")
var cd_gui_1 = preload("res://asset/CD_frame1.png")

func _ready():
	if GameData.current_skill_equipped == 2:
		skill_2_cd_gui.texture_over = cd_gui_1
	else:
		skill_2_cd_gui.texture_over = cd_gui_0

func cast_skill(state:SkillTree.Skill_Tree,lastAnimDir):
	player = get_parent()
	skill_state = state
	if state == SkillTree.Skill_Tree.LIGHTNING:
		thunder_eagle(lastAnimDir)
	elif state == SkillTree.Skill_Tree.WIND:
		gale_blades(lastAnimDir)
	elif state == SkillTree.Skill_Tree.WATER:
		serene_burst(lastAnimDir)


func _process(_delta):
	if !can_skill:
		skill_2_cd_gui.value = snapped(skill_cd.time_left,0.1)

func thunder_eagle(lastAnimDir):
	if can_skill:
		var projectile = load("res://scenes/projectile.tscn").instantiate()
		var skill_pos = player.position
		var shoot_dir
		match lastAnimDir:
			"Down":
				shoot_dir = Vector2(0,1)
			"Up":
				shoot_dir = Vector2(0,-1)
			"Left":
				shoot_dir = Vector2(-1,0)
			"Right":
				shoot_dir = Vector2(1,0)

		
		skill_pos.y += -15
		projectile.init(player.stats.att,shoot_dir,skill_pos,100,Vector2(-15,0),skill_state)
		get_node("/root/World").add_child(projectile)
		skill_cd.start(3)
		skilling_timer.start(0.2)
		player.velocity = Vector2.ZERO
		can_skill = false
		player.is_stunned = true
		is_skilling = true
		skill_2_cd_gui.texture_over = cd_gui_0
		skill_2_cd_gui.max_value = 3.0


func gale_blades(lastAnimDir):
	if can_skill:
		var projectile = load("res://scenes/projectile.tscn").instantiate()
		var projectile2 = load("res://scenes/projectile.tscn").instantiate()
		var projectile3 = load("res://scenes/projectile.tscn").instantiate()
		var skill_pos = player.position
		var shoot_dir
		match lastAnimDir:
			"Down":
				shoot_dir = Vector2(0,1)
			"Up":
				shoot_dir = Vector2(0,-1)
			"Left":
				shoot_dir = Vector2(-1,0)
			"Right":
				shoot_dir = Vector2(1,0)

		
		var dir_x2 = shoot_dir.x * cos(deg_to_rad(30)) - shoot_dir.y * sin(deg_to_rad(30))
		var dir_y2 = shoot_dir.x * sin(deg_to_rad(30)) + shoot_dir.y * cos(deg_to_rad(30))

		var dir_x3 = shoot_dir.x * cos(deg_to_rad(150)) - shoot_dir.y * sin(deg_to_rad(150))
		var dir_y3 = shoot_dir.x * sin(deg_to_rad(150)) + shoot_dir.y * cos(deg_to_rad(150))

		var shoot_dir2 = Vector2(dir_x2,dir_y2)
		var shoot_dir3 = Vector2(dir_x3,dir_y3)


		projectile.add_collision_exception_with(projectile2)
		projectile.add_collision_exception_with(projectile3)
		projectile.add_collision_exception_with(player)
		projectile2.add_collision_exception_with(projectile)
		projectile2.add_collision_exception_with(projectile3)
		projectile2.add_collision_exception_with(player)
		projectile3.add_collision_exception_with(projectile)
		projectile3.add_collision_exception_with(projectile2)
		projectile3.add_collision_exception_with(player)
		
		projectile.init(player.stats.att,shoot_dir,skill_pos,100,Vector2(-15,0),skill_state)
		projectile2.init(player.stats.att,shoot_dir2,skill_pos,100,Vector2(-15,0),skill_state)
		projectile3.init(player.stats.att,-shoot_dir3,skill_pos,100,Vector2(-15,0),skill_state)

		get_node("/root/World").add_child(projectile)
		get_node("/root/World").add_child(projectile2)
		get_node("/root/World").add_child(projectile3)

		skill_cd.start(3)
		skilling_timer.start(0.2)
		player.velocity = Vector2.ZERO
		can_skill = false
		player.is_stunned = true
		is_skilling = true
		skill_2_cd_gui.texture_over = cd_gui_0
		skill_2_cd_gui.max_value = 3.0


func serene_burst(lastAnimDir):
	if can_skill:
		var projectile = load("res://scenes/projectile.tscn").instantiate()
		var skill_pos = player.position
		var shoot_dir
		match lastAnimDir:
			"Down":
				shoot_dir = Vector2(0,1)
			"Up":
				shoot_dir = Vector2(0,-1)
			"Left":
				shoot_dir = Vector2(-1,0)
			"Right":
				shoot_dir = Vector2(1,0)

		projectile.init("LProjectile", player.stats.att,shoot_dir,skill_pos,100,Vector2(-15,0), skill_state)
		get_node("/root/World").add_child(projectile)
		skill_cd.start(3)
		skilling_timer.start(0.2)
		player.velocity = Vector2.ZERO
		can_skill = false
		player.is_stunned = true
		is_skilling = true
		skill_2_cd_gui.texture_over = cd_gui_0
		skill_2_cd_gui.max_value = 3.0



func _on_skilling_timer_timeout():
	is_skilling = false
	player.is_stunned = false
	player.doing_skill_2 = false



func _on_skill_timer_timeout():
	can_skill = true
	skill_2_cd_gui.texture_over = cd_gui_1


func set_equip(is_equipped:bool):
	if is_equipped:
		skill_2_cd_gui.texture_over = cd_gui_1
	else:
		skill_2_cd_gui.texture_over = cd_gui_0
