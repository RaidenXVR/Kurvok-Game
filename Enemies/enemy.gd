extends CharacterBody2D

class_name Enemy

signal killed(enemy_name)

# @export var enemy_texture:Texture2D
var speed:int = 30
var knockPower:int = 300
var detect_radius:int = 200
var col_hitbox_radius: int = 15
var attack_radius:int = 20
var move_pattern: Array[Dictionary]
var move_delay: float
var attack_delay: float
@export var enemy_res: EnemyData



@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var collision_box: CollisionShape2D = $CollisionShape2D
@onready var attack_shape:CollisionShape2D = $AttackBox/CollisionShape2D
# @onready var sprite_enemy = $Sprite2D
@onready var nav = $Navigation
@onready var health_bar_enemy = $HealthBar
@onready var pattern_timer = $PatternTimer
@onready var attack_timer = $AttackTimer
@onready var enemy_anim:AnimatedSprite2D = $AnimatedSprite2D
@onready var status_effects: Node2D = $StatusEffects
# @onready var player = get_tree().root.get_node("World").get_node("Player")


var enemy_stats :Stats
var enemy_type
var attack_patterns:Array[EnemyAttack]
var current_attack: EnemyAttack
var player_body
var timer = Timer.new()
var circle_shape:CircleShape2D
var capsule_shape: CapsuleShape2D
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
var is_slowed:bool = false
var is_stopped:bool = false
var drag_force = 0.0
var current_attack_idx:int = 0
var current_move_index:int = 0
var is_aoeing = false
var doing_aoe = false
var is_slashing = false
var doing_slash = false

func _ready():
	circle_shape = attack_shape.shape
	enemy_anim.sprite_frames = enemy_res.enemy_sprite_frames
	enemy_type = enemy_res.enemy_type
	attack_patterns = enemy_res.attack_patterns
	enemy_stats = enemy_res.enemy_stats.duplicate()
	speed = enemy_res.speed
	knockPower = enemy_res.knockPower
	detect_radius = enemy_res.detect_radius
	col_hitbox_radius = enemy_res.col_hitbox_radius
	move_delay = enemy_res.move_delay
	move_pattern = enemy_res.move_pattern
	attack_radius = enemy_res.attack_radius
	attack_delay = enemy_res.attack_delay
	detection_shape.shape.radius = detect_radius
	collision_box.shape.radius = col_hitbox_radius
	attack_shape.shape.radius = attack_radius

	current_attack = attack_patterns[current_attack_idx]

	add_child(timer)
	timer.connect("timeout",_on_timer_timeout)
	timer.one_shot = true
	timer.start(2)
	health_bar_enemy.init_amount(enemy_stats.mhp, enemy_stats.hp)
	health_bar_enemy.visible = false
	
	CutsceneManager.cutscene_started.connect(_on_started_cutscene_signal)
	CutsceneManager.finished_doing_cutscene.connect(_on_finished_cutscene_signal)
	
func _physics_process(_delta):
	if !is_stunned:
		if !is_chasing:
			if is_stopped : return
			if is_moving:
				velocity = target_coor.normalized() *speed
				colliding = move_and_slide()
				if last_pos == position and timer.is_stopped():
					timer.wait_time = move_delay
					timer.start()
				if (position.distance_to(initial_pos))>distance_must_travel or colliding:
					last_pos = position
					is_moving = false
					timer.wait_time = move_delay
					timer.start()

		else:
			var chase_dir =to_local(nav.get_next_path_position())
			velocity = chase_dir.normalized() * (speed+20)
			move_and_slide()	
	

	elif  is_knocked:
		velocity = velocity - (velocity*drag_force)
		drag_force+= 0.005
		move_and_slide()

	if is_aoeing:
		if player_body != null  and player_body.position.distance_to(global_position) < current_attack.distance_for_aoe:
			_aoe()
		nav.target_position = player_body.global_position
		var chase_dir =nav.get_next_path_position()
		velocity = chase_dir.normalized() * (speed+20)
		move_and_slide()
	
	if is_slashing:
		
		if player_body != null  and  player_body.position.distance_to(global_position) < current_attack.distance_for_slash:
			_slash()
			if not doing_slash:
				nav.target_position = player_body.global_position
				var chase_dir =to_local(nav.get_next_path_position())
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
			enemy_anim.play("walkDown")
			last_dir = "Down"
		elif rand_y<0:
			enemy_anim.play("walkUp")
			last_dir="Up"
		else:
			enemy_anim.play("idle"+last_dir)
			pass
	
	else:
		rand_x = randi_range(-3,3)
		if rand_x>0:
			enemy_anim.play("walkRight")
			last_dir = "Right"
		elif rand_x < 0:
			enemy_anim.play("walkLeft")
			last_dir="Left"
		else:
			enemy_anim.play("idle"+last_dir)
			pass
	print(enemy_anim.animation)
	distance_must_travel = 48* rand_dis
	target_coor = Vector2(rand_x*tileSize,rand_y*tileSize)

func determined_move():

	var current_move: Dictionary = move_pattern[current_move_index]
	var coor: Vector2
	if current_move.keys()[0] == "up":
		enemy_anim.play("walkUp")
		coor = Vector2(0,-1)
		last_dir = "Up"
	elif current_move.keys()[0] == "down":
		enemy_anim.play("walkDown")
		coor = Vector2(0,1)
		last_dir = "Down"
	elif current_move.keys()[0] == "left":
		enemy_anim.play("walkLeft")
		coor = Vector2(-1,0)
		last_dir = "Left"
	elif current_move.keys()[0] == "right":
		enemy_anim.play("walkRight")
		coor = Vector2(1,0)
		last_dir = "Right"
	elif current_move.keys()[0] == "stop":
		enemy_anim.play("idle"+last_dir)
		coor = Vector2(0,0)
		is_stopped = true
		timer.start(current_move["stop"])
		await timer.timeout
		is_stopped = false
		timer.wait_time = move_delay

	distance_must_travel = 48 * current_move.values()[0]
	target_coor = coor * 48 * current_move.values()[0]
	current_move_index +=1
	if current_move_index >= len(move_pattern):
		current_move_index = 0

func _on_timer_timeout():
	if is_stopped: return
	if is_aoeing:
		attack_shape.shape.radius = enemy_res.attack_radius
		is_aoeing = false
		is_stunned = false
		doing_aoe = false
		
	if !is_chasing and !is_stunned:
		initial_pos = position
		if not move_pattern:
			random_desti()
		else:
			determined_move()
		is_moving = true
		timer.wait_time = move_delay

	elif is_chasing and !is_stunned:
		nav.target_position = player_body.global_position

	elif is_stunned :
		timer.one_shot = false
		is_stunned = false
		is_knocked = false
		drag_force = 0.0
	if player_body != null:
		nav.target_position = player_body.global_position
		timer.wait_time = 0.5
		timer.start()


func _on_attack_timer_timeout():
	attack_timer.stop()
	is_stunned = false
	is_knocked = false
	if is_aoeing:
		attack_shape.shape.radius = enemy_res.default_shape_radius
		is_aoeing = false
		is_stunned = false
		doing_aoe = false
	
	if is_slashing:
		attack_shape.shape.radius = enemy_res.default_shape_radius 
		attack_shape.position = Vector2.ZERO
		is_slashing = false
		is_stunned = false
		doing_slash = false


func _on_detection_area_body_entered(body:Node2D):
	if body is Player:
		player_body = body
	#if body is Player and not is_stunned and not is_knocked:
		is_chasing = true
		nav.target_position = body.global_position
		player_body = body
		timer.one_shot = false
		timer.wait_time = 0.5
		timer.start()
		health_bar_enemy.visible = true
		pattern_timer.emit_signal("timeout")
		pattern_timer.start(attack_delay)




func _on_detection_area_body_exited(body:Node2D):
	if body is Player:
		if is_queued_for_deletion():
			return
		is_chasing = false
		timer.stop()
		timer.one_shot = true
		timer.wait_time = move_delay
		timer.start()
		health_bar_enemy.visible = false
		pattern_timer.stop()
		current_attack_idx = 0
		player_body = null

func damaged(damage):
	enemy_stats.take_damage(damage)
	health_bar_enemy.health = enemy_stats.hp

	if enemy_stats.hp <=0:
		GameData.enemy_slayed(enemy_type)
		QuestManager.check_target(enemy_type,1)
		if QuestManager.current_main_quest:
			QuestManager.current_main_quest.check_target(enemy_type,1)
		queue_free()

func knockback(attack_dir: Vector2, knock_power = 500):
	velocity = Vector2.ZERO
	var knockDir = attack_dir.normalized() * knock_power
	velocity = knockDir
	move_and_slide()
	is_stunned = true
	is_knocked = true
	timer.one_shot = true
	timer.wait_time = 0.8
	timer.start()

func _on_attack_box_body_entered(body:Node2D):
	if body is Player and not body.is_immune and not body.is_knocked:
		body.take_damage(enemy_stats.do_damage())
		if !is_aoeing:
				body.knockback(position, knockPower)
				knockback(body.position)
		if current_attack.effect != null:
			body.add_status_effect(current_attack.effect)

		


func _on_pattern_timer_timeout():
	speed = 30
	is_aoeing = false
	doing_aoe = false
	is_slashing = false
	doing_slash = false
	current_attack = attack_patterns[current_attack_idx]
	if current_attack.attack_type == EnemyAttack.EnemyAttackType.ENEMY_TOUCH:
		touch()
	elif current_attack.attack_type == EnemyAttack.EnemyAttackType.ENEMY_SLASH:
		slash()
	elif current_attack.attack_type == EnemyAttack.EnemyAttackType.ENEMY_SHOOT:
		shoot()
	elif current_attack.attack_type == EnemyAttack.EnemyAttackType.ENEMY_AREA:
		aoe()
	elif current_attack.attack_type == EnemyAttack.EnemyAttackType.ENEMY_MULTISHOT:
		projectile_multi()

	if current_attack_idx >= attack_patterns.size()-1:
		current_attack_idx = 0
	else:
		current_attack_idx +=1
	
func touch():
	speed =current_attack.speed_mod
	

func slash():

	speed = current_attack.speed_mod
	#if capsule_shape == null:
		#capsule_shape = CapsuleShape2D.new()
	attack_shape.disabled = true
	#attack_shape.shape = capsule_shape
	attack_shape.shape.radius = current_attack.shape_radius
	#attack_shape.shape.height = current_attack.shape_height
	is_slashing = true
	
func _slash():
	if not doing_slash and is_slashing:
		doing_slash = true
		is_stunned  = true
		attack_shape.disabled = false
		var target_pos = position.direction_to(player_body.position)
		if target_pos.abs().x > target_pos.abs().y:
			if target_pos.x > position.x:
				enemy_anim.play("attackRight")
				attack_shape.position = Vector2(current_attack.slash_shape_offset, 0)

			else:
				enemy_anim.play("attackLeft")
				attack_shape.position = Vector2(-current_attack.slash_shape_offset, 0)

		else:
			if target_pos.y > position.y:
				enemy_anim.play("attackDown")
				attack_shape.position = Vector2(0, current_attack.slash_shape_offset)

			else:
				enemy_anim.play("attackUp")
				attack_shape.position = Vector2(0, -current_attack.slash_shape_offset)
		velocity = Vector2.ZERO

		attack_timer.start(current_attack.stun_duration)
		
	
	

func shoot():
	var projectile = load("res://scenes/projectile.tscn").instantiate()
	var skill_pos = position
	var shoot_dir:Vector2
	var player_pos = player_body.position
	shoot_dir = skill_pos.direction_to(player_pos)
	is_stunned = true
	attack_timer.start(current_attack.stun_duration)

	projectile.add_collision_exception_with(self)
	projectile.init(enemy_stats.att,shoot_dir,skill_pos, current_attack.projectile_res)
	get_node("/root/World").call_deferred("add_child", projectile)

func aoe():
	is_aoeing = true
	speed = current_attack.speed_mod


func _aoe():
	if !doing_aoe and is_aoeing:
		velocity = Vector2.ZERO
		attack_shape.shape.radius = current_attack.shape_radius
		is_stunned = true
		attack_timer.start(current_attack.stun_duration)
		doing_aoe = true

func projectile_multi():

	var skill_pos = global_position
	var shoot_dir:Vector2
	var player_pos = player_body.global_position
	shoot_dir = skill_pos.direction_to(player_pos) * 100
	velocity = Vector2.ZERO
	# is_stunned = true
	_projectile_multi(shoot_dir, skill_pos)
	attack_timer.start(1)

func _projectile_multi(shoot_dir,skill_pos):
	var projectiles_count = current_attack.num_projectile
	var is_full_circle = current_attack.is_full_circle_division
	if projectiles_count % 2 == 0:
		# Ensure that num_projectiles is odd, add 1 if it's even.
		projectiles_count += 1
		
		var angle_step = 180.0 / (projectiles_count)
		if is_full_circle:
			angle_step = 360.0 / (projectiles_count)
		var projectiles = []
		var shoot_dirs = []
		# Calculate half the spread angle (to distribute projectiles symmetrically)
		@warning_ignore("integer_division")
		var start_angle = -angle_step * ((projectiles_count - 1) / 2)
		for i in range(projectiles_count):
			var projectile = load("res://scenes/projectile.tscn").instantiate()
			var current_angle = start_angle + i * angle_step
			var rad = deg_to_rad(current_angle)
			
			var dir_x = shoot_dir.x * cos(rad) - shoot_dir.y * sin(rad)
			var dir_y = shoot_dir.x * sin(rad) + shoot_dir.y * cos(rad)
			projectiles.append(projectile)
			shoot_dirs.append(Vector2(dir_x, dir_y))
		
		
		skill_pos.y += -15
		for i in range(len(projectiles)):
			var projectile = projectiles[i]
			projectile.init(enemy_stats.stats.att,shoot_dirs[i],skill_pos,current_attack.projectile_res)
			get_node("/root/World").add_child(projectile)


func status_effect_damage(effect_type: StatusEffect.EffectType,effect_timer:Timer, damage:int  = 0):
	match effect_type:
		StatusEffect.EffectType.EFFECT_POISON:
			enemy_stats.take_flat_damage(damage)
			health_bar_enemy.health = enemy_stats.hp
			if enemy_stats.hp < 0:
				queue_free()
		StatusEffect.EffectType.EFFECT_STUN:
			is_stunned = true
			await effect_timer.timeout
			is_stunned = false
		StatusEffect.EffectType.EFFECT_SLOW:
			is_slowed = true
			speed = damage
			await effect_timer.timeout


func add_status_effect(effect: Effect):
	var status_effect_node = StatusEffect.new(effect)
	status_effects.add_child(status_effect_node)


func _on_started_cutscene_signal():
	set_physics_process(false)

func _on_finished_cutscene_signal():
	set_physics_process(true)
