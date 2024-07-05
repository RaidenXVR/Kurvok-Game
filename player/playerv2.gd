extends CharacterBody2D

class_name Player

signal HPChanged
signal is_talking

@export var speed:int=120
@export var maxHP:int = 20
@export var knockPower:int =250
@export var stats: Stats

@onready var timer = $Timer
@onready var hurtTimer = $hurtTimer
@onready var animation = $AnimationPlayer
@onready var attack_box = $AttackBox
@onready var attack_box_shape = $AttackBox/CollisionPolygon2D
@onready var player_healthbar = get_parent().get_node("CanvasLayer/PlayerHealthBar")
@onready var manabar = get_node("/root/World/CanvasLayer/ManaBar")
@onready var player_attack_sprite = $AttackSprite
@onready var player_sprite = $Sprite2D
@onready var look_dir: RayCast2D = $LookDir
@onready var combo_timer:Timer = $ComboTimer

@onready var skill_1 = $Skill1
@onready var skill_2 = $Skill2
@onready var skill_3 = $Skill3

var circle_shape = Shapes.get_circle_points(50)
var default_shape = Shapes.get_any_degree_torus_points(10,40,150)
var wider_default_shape = Shapes.get_any_degree_torus_points(10,50,180)
var lightning_lance = Shapes.get_lance_points(80,20)

var attack_sprites = preload("res://asset/LaylaAttackWeapon.png")
var cd_gui_0 = preload("res://asset/CD_frame0.png")
var cd_gui_1 = preload("res://asset/CD_frame1.png")
var inventory: Inventory

var lastAnimDir: String = "Down"
var is_stunned : bool = false
var currentHealth : int = maxHP
var is_damaged: bool = false
var is_attacking: bool = false
var moveDir
var can_open_chest: bool = false
var can_talk:bool = false
var can_shop
var temp_area: Area2D
var temp_body: PhysicsBody2D
var is_knocked:bool = false
var drag_force = 0.0
var is_skilling = false
var doing_skill_1:bool =false
var doing_skill_2:bool = false
var doing_skill_3:bool = false
var equiped_skill_tree = GameData.current_skill_tree
var viewport_rect
var equipped_skill = GameData.current_skill_equipped
var combo_count: int = 0


func _ready():
	inventory  = GameData.player_inventory
	attack_box.monitoring = false
	player_healthbar.init_amount(stats.mhp, stats.hp)
	manabar.init_amount(stats.max_mana, stats.mana)
	var viewport = get_viewport() as Viewport
	viewport_rect = viewport.get_visible_rect()
	if GameData.player_position != null:
		global_position = GameData.player_position
	
	attack_box_shape.polygon = default_shape
	# default_shape = attack_box_shape.shape

func handleInput():
	if is_knocked:
		velocity = velocity - (velocity*drag_force)
		drag_force+=0.01
		return

	if is_skilling:
		return

	if doing_skill_1 or doing_skill_2 or doing_skill_3:
		return
	#get input from player
	moveDir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	#Looking direction
	if (moveDir.x<0 and velocity.length() == 0 and !is_attacking):
		animation.play("walkLeft")
		lastAnimDir = "Left"
		look_dir.target_position = Vector2(-1,0) *20
		animation.stop()
	elif(moveDir.x>0 and velocity.length() == 0 and !is_attacking):
		animation.play("walkRight")
		lastAnimDir = "Right"
		look_dir.target_position = Vector2(1,0) *20
		animation.stop()
	elif (moveDir.y<0 and velocity.length() == 0 and !is_attacking):
		animation.play("walkDown")
		lastAnimDir = "Down"
		look_dir.target_position = Vector2(0,1) *20
		animation.stop()
	elif moveDir.y>0 and velocity.length() == 0 and !is_attacking:
		animation.play("walkUp")
		lastAnimDir = "Up"
		look_dir.target_position = Vector2(0,-1) *20
		animation.stop()
	elif moveDir == Vector2.ZERO:
		# look_dir.target_position = look_dir.position
		pass
	else:
		look_dir.target_position = Vector2(moveDir.x, -moveDir.y) *20

		
	#Switch to run
	if Input.is_action_pressed("run"):
		speed = 230
		animation.speed_scale = 2
	else:
		speed = 120
		animation.speed_scale = 1
	
	#for if the player is stunned
	if is_stunned:
		moveDir = Vector2.ZERO
	
	#moving
	moveDir.y = -moveDir.y

	velocity = moveDir *speed
	#attack logic
	if Input.is_action_just_pressed("attack"):
		if combo_count != 0:
			combo_attack()
		elif combo_count == 0 and combo_timer.is_stopped():
			combo_count +=1
			match lastAnimDir:
				"Down":
					attack_box.rotation_degrees = 60
				"Up":
					attack_box.rotation_degrees = 210
				"Right":
					attack_box.rotation_degrees = -30
				"Left":
					attack_box.rotation_degrees = 120
				
			animation.play("attack"+lastAnimDir)
			is_attacking = true
			is_stunned = true
			attack_box.monitoring = true
			await animation.animation_finished
			attack_box.monitoring = false
			is_stunned = false
			is_attacking = false
			combo_timer.start()

	
func updateAnimation():
	if is_attacking: 
		return
	if is_skilling:
		return
	if doing_skill_1:
		return
	if velocity.length() == 0:
		if moveDir == Vector2.ZERO:
			animation.play("walk"+lastAnimDir)
			animation.stop()

	else:
		var dir = "Down"
		if !is_knocked:
				if velocity.x < 0: dir = "Left"
				elif velocity.x > 0 : dir = "Right"
				elif velocity.y<0: dir = "Up"

		else:
			if abs(velocity.x)>abs(velocity.y):
				if velocity.x > 0: dir = "Left"
				elif velocity.x < 0 : dir = "Right"
			else:
				if velocity.y>0: dir = "Up"
				elif velocity.y<0:dir = "Down"
		lastAnimDir = dir
		animation.play("walk"+dir)
		
func _physics_process(_delta):
	var target = look_dir.get_collider()
	if target is NPC:
		can_talk = true
	elif target is ItemHolder:
		can_open_chest = true
	elif target is Shop:
		temp_body = target
		can_shop = true

	elif target is PhysicsBody2D:
		temp_body = target
	else:
		can_talk = false
		can_open_chest = false
		can_shop = false
	# print(target)
	if target is EntryPoint:
		if target.name == "westPoint":
			target.get_parent().get_parent()._on_west_point_body_entered(self)
		elif target.name == "eastPoint":
			target.get_parent().get_parent()._on_east_point_body_entered(self)


	
	handleInput()
	move_and_slide()
	updateAnimation()

func combo_attack():
	if equiped_skill_tree == SkillTree.Skill_Tree.LIGHTNING:
		match combo_count:
			1:

				combo_count +=1
				attack_box_shape.polygon = wider_default_shape
				match lastAnimDir:
					"Down":
						attack_box.rotation_degrees = 30
					"Right":
						attack_box.rotation_degrees = -60
				combo_timer.start()
				pass
			2:

				combo_count +=1
				attack_box_shape.polygon = lightning_lance
				combo_timer.start(0.6)
				pass
			_:
				return

		animation.play("attack"+lastAnimDir)
		is_attacking = true
		is_stunned = true
		attack_box.monitoring = true
		await animation.animation_finished
		attack_box.monitoring = false
		is_stunned = false
		is_attacking = false


func _input(event):
	if position.y <= viewport_rect.position.y+100:
		player_healthbar.get_parent().set_alpha(true)
	else:
		player_healthbar.get_parent().set_alpha(false)

	if event.is_action_pressed("interact") and can_open_chest:
		open_chest()
	elif event.is_action_pressed("interact") and can_talk and temp_body is NPC:
		can_talk = false
		var facing = -to_local(temp_body.position).normalized()
		if facing.x >= facing.y:
			if facing.x >= 0:
				temp_body.animation_player.stop()
				temp_body.sprite_npc.frame_coords = Vector2(0,3)
				
			else:
				temp_body.animation_player.stop()

				temp_body.sprite_npc.frame_coords = Vector2(0,1)
				
		else :
			if facing.y >= 0:
				temp_body.animation_player.stop()
				temp_body.sprite_npc.frame_coords = Vector2(0,2)

			else:
				temp_body.animation_player.stop()
				temp_body.sprite_npc.frame_coords = Vector2(0,0)
		
		temp_body.is_moving = false
		if temp_body.isNPCCanMove:
			temp_body.timer.start(2)
		temp_body.talk()
	
	elif event.is_action_pressed("interact") and temp_body is Shop and can_shop == true:
		temp_body.open_shop()
	
	if Input.is_action_just_pressed("skill_1"):
		GameData.current_skill_equipped = 1
		equipped_skill = GameData.current_skill_equipped
		skill_1.set_equip(true)
		skill_2.set_equip(false)
		skill_3.set_equip(false)

	elif Input.is_action_just_pressed("skill_2"):
		GameData.current_skill_equipped = 2
		equipped_skill = GameData.current_skill_equipped
		skill_1.set_equip(false)
		skill_2.set_equip(true)
		skill_3.set_equip(false)

	elif Input.is_action_just_pressed("skill_3"):
		GameData.current_skill_equipped = 3
		equipped_skill = GameData.current_skill_equipped
		skill_1.set_equip(false)
		skill_2.set_equip(false)
		skill_3.set_equip(true)

	if Input.is_action_just_pressed("use_skill"):
		match equipped_skill:
			1:
				skill_1.cast_skill(equiped_skill_tree, lastAnimDir)
			2:
				skill_2.cast_skill(equiped_skill_tree, lastAnimDir)
			3:
				skill_3.cast_skill(equiped_skill_tree)

	
	if Input.is_action_just_pressed("temp_save"):
		GameData.save_game()

func open_chest():
	if temp_body != null and temp_body.has_method("collect"):
		temp_body.collect()
		temp_body = null

func unstun():
	timer.stop()
	is_stunned = false
	is_knocked = false
	drag_force = 0.0
func unHurt():
	hurtTimer.stop()
	is_damaged = false

func knockback(enemyPosition: Vector2):
	velocity = Vector2.ZERO
	var knockDir = (enemyPosition - position).normalized() * knockPower
	velocity = -knockDir
	move_and_slide()
	is_stunned = true
	is_knocked = true
	timer.start(0.8)
	

func heal(amount:int):
	stats.heal_self(amount)
	HPChanged.emit(amount)
	player_healthbar._set_amount(stats.hp)

func on_tp_player(coor):
	position = coor


func _on_hitbox_area_exited(area):
	if area.has_method("collect"):
		can_open_chest = false
		temp_area = null
	if area.has_method("talk"):
		can_talk = false
		temp_area= null


func _on_attack_box_area_entered(area:Area2D):

	area.get_parent().damaged(stats.do_damage())
	area.get_parent().knockback(velocity)
	

func _on_attack_box_body_entered(body:Node2D):
	if body is Projectile and body.from_enemy:
		body.velocity = Vector2.ZERO
		body.queue_free()

func take_damage(damage):
	if is_damaged: return
	if is_stunned: return
	if is_skilling: return

	stats.take_damage(damage)
	player_healthbar.health = stats.hp
	if stats.hp < 0:
		stats.hp = maxHP
	HPChanged.emit(stats.hp)
	hurtTimer.start(1)
	is_damaged = true

func quest_trigger(quest_name,type, objective, amn):
	GameData.add_quest(quest_name, type, objective, amn)


func _on_combo_timer_timeout():
	attack_box_shape.polygon = default_shape
	attack_box.position = Vector2(0,-11.5)
	combo_count = 0




