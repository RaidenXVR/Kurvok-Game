extends CharacterBody2D

class_name Enemy

signal killed(enemy_name)

@export var enemy_texture:Texture2D
@export var enemy_stats :Stats = Stats.new()
@export var speed:int = 30
@export var knockPower:int = 300
@export var detect_radius:int = 200
@export var col_hitbox_radius: int = 15
@export var attack_radius:int = 20
@export var enemy_type:String 
@export var attack_pattern:Array[String]


@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var collision_box: CollisionShape2D = $CollisionShape2D
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var attack_shape:CollisionShape2D = $AttackBox/CollisionShape2D
@onready var sprite_enemy = $Sprite2D
@onready var nav = $Navigation
@onready var health_bar_enemy = $HealthBar
@onready var pattern_timer = $PatternTimer
@onready var attack_timer = $AttackTimer

# @onready var player = get_tree().root.get_node("World").get_node("Player")



var player_body
var timer = Timer.new()
var distance_must_travel = 48
var initial_pos
var is_moving: bool = false
var tileSize = 48
var target_coor:Vector2
var colliding:bool = false
var last_dir: String = "Down"
var last_pos
var is_chasing:bool = false
var is_stunned: bool = false
var is_knocked:bool = false
var drag_force = 0.0
var current_attack_idx:int = 0
var is_aoeing = false
var doing_aoe = false

func _ready():
	sprite_enemy.texture = enemy_texture
	detection_shape.shape.radius = detect_radius
	collision_box.shape.radius = col_hitbox_radius
	hitbox_shape.shape.radius = col_hitbox_radius
	attack_shape.shape.radius = attack_radius

	add_child(timer)
	timer.connect("timeout",_on_timer_timeout)
	timer.one_shot = true
	timer.start(2)
	health_bar_enemy.init_amount(enemy_stats.mhp, enemy_stats.hp)
	health_bar_enemy.visible = false
	

func _physics_process(_delta):
	if !is_stunned:
		if !is_chasing:
			if is_moving:
				velocity = target_coor.normalized() *speed
				colliding = move_and_slide()
				if last_pos == position and timer.is_stopped():
					timer.start(2)
					pass
				if (position.distance_to(initial_pos))>distance_must_travel or colliding:
					last_pos = position
					is_moving = false
					timer.start(2)
				
# if player_body != null:
			# 	if detection_area.overlaps_body(player_body):
			# 		is_chasing = true
			# 	else:
			# 		is_chasing = false

		else:
			var chase_dir =to_local(nav.get_next_path_position())
			velocity = chase_dir.normalized() * (speed+20)
			move_and_slide()	
	

	elif is_knocked:
		velocity = velocity - (velocity*drag_force)
		drag_force+= 0.01
		move_and_slide()

	if is_aoeing:
		if player_body.position.distance_to(global_position) < 200:
			_aoe()
		nav.target_position = player_body.global_position
		var chase_dir =nav.get_next_path_position()
		velocity = chase_dir.normalized() * (speed+20)
		move_and_slide()

func random_desti():
	var rand_dis = randi_range(0,5)
	var rand = randi_range(0,1)
	var rand_y = 0
	var rand_x = 0
	
	if rand == 0:
		rand_y = randi_range(-3,3)
		if rand_y >0 :
			# animation_player.play("walkDown")
			last_dir = "Down"
		elif rand_y<0:
			# animation_player.play("walkUp")
			last_dir="Up"
		else:
			# animation_player.play("idle"+last_dir)
			pass
	
	else:
		rand_x = randi_range(-3,3)
		if rand_x>0:
			# animation_player.play("walkRight")
			last_dir = "Right"
		elif rand_x < 0:
			# animation_player.play("walkLeft")
			last_dir="Left"
		else:
			# animation_player.play("idle"+last_dir)
			pass
	distance_must_travel = 48* rand_dis
	target_coor = Vector2(rand_x*tileSize,rand_y*tileSize)



func _on_timer_timeout():
# print(is_chasing, is_stunned)
	if is_aoeing:
		attack_shape.shape.radius = 20
		is_aoeing = false
		is_stunned = false
		doing_aoe = false
		
	if !is_chasing and !is_stunned:
		initial_pos = position
		random_desti()
		is_moving = true
	elif is_chasing and !is_stunned:
		nav.target_position = player_body.global_position

	elif is_stunned :
		timer.one_shot = false
		is_stunned = false
		is_knocked = false
		drag_force = 0.0
	if player_body != null:
		nav.target_position = player_body.global_position
		timer.start(0.5)


func _on_attack_timer_timeout():
	attack_timer.stop()
	is_stunned = false
	is_knocked = false
	if is_aoeing:
		attack_shape.shape.radius = 20
		is_aoeing = false
		is_stunned = false
		doing_aoe = false


func _on_detection_area_body_entered(body:Node2D):
	if body is Player:
		player_body = body
	if body is Player and not is_stunned and not is_knocked:
		is_chasing = true
		nav.target_position = body.global_position
		player_body = body
		timer.one_shot = false
		timer.start(0.5)
		health_bar_enemy.visible = true
		pattern_timer.emit_signal("timeout")
		pattern_timer.start(2)




func _on_detection_area_body_exited(body:Node2D):
	if body is Player:
		if is_queued_for_deletion():
			return
		is_chasing = false
		timer.stop()
		timer.one_shot = true
		timer.start(2)
		health_bar_enemy.visible = false
		pattern_timer.stop()
		current_attack_idx = 0

func damaged(damage):
	enemy_stats.take_damage(damage)
	health_bar_enemy.health = enemy_stats.hp
	
	if enemy_stats.hp <=0:
		GameData.enemy_slayed(enemy_type)
		QuestManager.check_target(enemy_type,1)
		queue_free()

func knockback(enemyPosition: Vector2, knock_power = 300):
	velocity = Vector2.ZERO
	var knockDir = (enemyPosition - position).normalized() * knock_power
	velocity = -knockDir
	move_and_slide()
	is_stunned = true
	is_knocked = true
	timer.one_shot = true
	timer.start(0.8)

func _on_attack_box_body_entered(body:Node2D):
	if body.name == "Player":
		body.take_damage(enemy_stats.do_damage())
		if !is_aoeing:
				print("knoc")
				body.knockback(position)
				knockback(body.position)
		


func _on_pattern_timer_timeout():
	speed = 30
	is_aoeing = false
	doing_aoe = false
	if attack_pattern[current_attack_idx] == "t":
		touch()
	elif attack_pattern[current_attack_idx] == "p":
		shoot()
	elif attack_pattern[current_attack_idx] == "a":
		aoe()
	elif attack_pattern[current_attack_idx] == "pm":
		projectile_multi()

	if current_attack_idx >= attack_pattern.size()-1:
		current_attack_idx = 0
	else:
		current_attack_idx +=1
	
func touch():
	speed = 60

func shoot():
	var projectile = load("res://scenes/projectile.tscn").instantiate()
	var skill_pos = position
	var shoot_dir:Vector2
	var player_pos = player_body.position
	shoot_dir = skill_pos.direction_to(player_pos)
	is_stunned = true
	attack_timer.start(0.5)

	projectile.add_collision_exception_with(self)
	projectile.init(enemy_stats.att,shoot_dir,skill_pos,100,Vector2(-15,0), SkillTree.Skill_Tree.ENEMY)
	get_node("/root/World").call_deferred("add_child", projectile)

func aoe():
	is_aoeing = true
	speed = 60


func _aoe():
	if !doing_aoe and is_aoeing:
		velocity = Vector2.ZERO
		attack_shape.shape.radius = 100
		is_stunned = true
		attack_timer.start(0.7)
		doing_aoe = true

func projectile_multi():

	var skill_pos = global_position
	var shoot_dir:Vector2
	var player_pos = player_body.global_position
	shoot_dir = skill_pos.direction_to(player_pos) * 100
	velocity = Vector2.ZERO
	# is_stunned = true
	_projectile_multi(shoot_dir, skill_pos, 5)
	attack_timer.start(1)

func _projectile_multi(shoot_dir,skill_pos, odd_num_of_projectile:int):
	var projectiles = []
	var angle_degree = 120.0/(odd_num_of_projectile-1)
	var i = 0
	var deg_mul = 0
	while i < odd_num_of_projectile:
		if i == 0:
			var projectile = load("res://scenes/projectile.tscn").instantiate()
			projectile.init(enemy_stats.att,shoot_dir.normalized(),skill_pos,100,Vector2(-15,0), SkillTree.Skill_Tree.ENEMY)
			projectile.add_collision_exception_with(self)
			projectiles.append(projectile)
			i+=1
		else:
			var projectile1 = load("res://scenes/projectile.tscn").instantiate()
			var projectile2 = load("res://scenes/projectile.tscn").instantiate()
			
			var dgr = angle_degree * deg_mul
			var dir_x = shoot_dir.x * cos(deg_to_rad(dgr)) - shoot_dir.y * sin(deg_to_rad(dgr))
			var dir_y = shoot_dir.x * sin(deg_to_rad(dgr)) + shoot_dir.y * cos(deg_to_rad(dgr))

			var dir_x2 = shoot_dir.x * cos(deg_to_rad(-dgr)) - shoot_dir.y * sin(deg_to_rad(-dgr))
			var dir_y2 = shoot_dir.x * sin((deg_to_rad(-dgr))) + shoot_dir.y * cos((deg_to_rad(-dgr)))
			
			projectile1.init(enemy_stats.att,Vector2(dir_x,dir_y).normalized(),skill_pos,100,Vector2(-15,0), SkillTree.Skill_Tree.ENEMY)
			projectile2.init(enemy_stats.att,Vector2(dir_x2,dir_y2).normalized(),skill_pos,100,Vector2(-15,0), SkillTree.Skill_Tree.ENEMY)

			projectile1.add_collision_exception_with(self)
			projectile2.add_collision_exception_with(self)

			projectiles.append(projectile1)
			projectiles.append(projectile2)
		
			i+=2
		deg_mul +=1
	
	var j = 0
	while j < projectiles.size():
		var k = 0
		while k < projectiles.size():
			projectiles[j].add_collision_exception_with(projectiles[k])
			projectiles[k].add_collision_exception_with(projectiles[j])
			k+=1
		j+=1
	
	for prj in projectiles:
		get_node("/root/World").call_deferred("add_child", prj)

func effect_self(_effect_key, _duration):

	pass
