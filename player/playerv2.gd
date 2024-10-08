extends CharacterBody2D

class_name Player

signal is_talking
signal combo


@export var speed:int=120
@export var maxHP:int = 20
@export var knockPower:int =250
@export var stats: Stats

@onready var timer = $Timer
@onready var hurtTimer = $hurtTimer
@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var attack_box = $AttackBox
@onready var attack_box_shape:CollisionShape2D = $AttackBox/CollisionShape2D
@onready var player_healthbar = get_parent().get_node("CanvasLayer/PlayerHealthBar")
@onready var manabar = get_node("/root/World/CanvasLayer/ManaBar")
@onready var player_attack_sprite = $AttackSprite
@onready var player_sprite = $Sprite2D
@onready var look_dir: RayCast2D = $LookDir
@onready var combo_timer:Timer = $ComboTimer
@onready var combo_timer2: Timer = $ComboTimer2
@onready var vfx_node:AnimatedSprite2D = $VFX

@onready var skill_1 = $Skills/Skill1
@onready var skill_2 = $Skills/Skill2
@onready var skill_3 = $Skills/Skill3

@onready var status_effects = $Effects

var circle_shape = CircleShape2D.new()
var capsule_shape = CapsuleShape2D.new()
var rect_shape = RectangleShape2D.new()

var attack_sprites = preload("res://asset/LaylaAttackWeapon.png")
var cd_gui_0 = preload("res://asset/CD_frame0.png")
var cd_gui_1 = preload("res://asset/CD_frame1.png")
var sword_woosh1 = preload("res://Audio/sword_woosh1.wav")
var sword_woosh2 = preload("res://Audio/sword_woosh2.wav")
var sword_woosh3 = preload("res://Audio/sword_woosh3.wav")
var inventory: Inventory

var lastAnimDir: String = "Down"
var is_stunned : bool = false
var currentHealth : int = maxHP
var is_damaged: bool = false
var is_attacking: bool = false
var is_immune:bool = false
var is_slowed:bool = false
var is_confused:bool = false
var moveDir
var can_open_chest: bool = false
var can_talk:bool = false
var can_shop
var can_read_sign
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
var combo_count: int = 0
var slide_amount = 1.0
var input_buffered = false
var attack_duration = 0.0
var halfway_point = 0.2
var can_attack:bool = true

func _ready():
	inventory  = GameData.player_inventory
	stats = GameData.player_stats
	#attack_box.monitoring = false
	player_healthbar.init_amount(stats.mhp, stats.hp)
	manabar.init_amount(stats.max_mana, stats.mana)
	var viewport = get_viewport() as Viewport
	viewport_rect = viewport.get_visible_rect()
	if GameData.player_position != null:
		global_position = GameData.player_position
	
	CutsceneManager.cutscene_started.connect(_on_started_cutscene_signal)
	CutsceneManager.finished_doing_cutscene.connect(_on_finished_cutscene_signal)
	# default_shape = attack_box_shape.shape


func handleInput():
	if CutsceneManager.doing_cutscene:
		return
	if is_knocked:
		velocity = velocity - (velocity*drag_force)
		drag_force+=0.005
		move_and_slide()
		return

	if is_skilling:
		return

	if doing_skill_1 or doing_skill_2 or doing_skill_3:
		return
	#get input from player
	moveDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if is_confused:
		moveDir = -moveDir
	
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
	elif (moveDir.y>0 and velocity.length() == 0 and !is_attacking):
		animation.play("walkDown")
		lastAnimDir = "Down"
		look_dir.target_position = Vector2(0,1) *20
		animation.stop()
	elif moveDir.y<0 and velocity.length() == 0 and !is_attacking:
		animation.play("walkUp")
		lastAnimDir = "Up"
		look_dir.target_position = Vector2(0,-1) *20
		animation.stop()
	elif moveDir == Vector2.ZERO:
		# look_dir.target_position = look_dir.position
		pass
	else:
		look_dir.target_position = Vector2(moveDir.x, moveDir.y) *20
	
		
	#Switch to run
	if Input.is_action_pressed("run") and not is_stunned and not is_attacking and not is_slowed:
		AudioManager.audio_players["sfx"]
		speed = 230
		animation.speed_scale = 2
	elif is_slowed:
		pass
	else:
		speed = 120
		animation.speed_scale = 1
	
	#for if the player is stunned
	if is_stunned:
		moveDir = Vector2.ZERO
	
	#moving
	#moveDir.y = -moveDir.y
	if not is_attacking:
		velocity = moveDir *speed
		slide_amount = 0
	else:
		if not velocity.is_zero_approx():
			velocity -= (velocity.normalized()*Vector2(slide_amount, slide_amount))
			slide_amount +=0.7
		else :
			velocity = Vector2.ZERO
	
		
	#attack logic
	if Input.is_action_just_pressed("attack"):
		if is_attacking:
			# Buffer the input if the player presses the attack button during an attack
			input_buffered = true
		elif can_attack:
			start_attack()
	#elif Input.is_action_just_pressed("attack") and not combo_timer2.is_stopped():
		#print("not stopped")
		#pass



func start_attack():
	# Delay between attacks to avoid snappy feeling
	if GameData.weapon_equip == null:
		return
	if not can_attack:
		return
	
	can_attack = false
	var combo_step: ComboStep = GameData.skill_passive.combo_steps[combo_count]
	attack_box_shape.disabled = false
	
	# Set up the shape according to the combo step
	match combo_step.shape:
		ComboStep.ComboShape.COMBO_CAPSULE:
			attack_box_shape.shape = capsule_shape
			attack_box_shape.shape.radius = combo_step.radius
			attack_box_shape.shape.height = combo_step.height
			attack_box_shape.rotation_degrees = combo_step.rotation_offset
		ComboStep.ComboShape.COMBO_CIRCLE:
			attack_box_shape.shape = circle_shape
			attack_box_shape.radius = combo_step.radius
			attack_box_shape.rotation_degrees = combo_step.rotation_offset
		ComboStep.ComboShape.COMBO_RECT:
			attack_box_shape.shape = rect_shape
			attack_box_shape.size = Vector2(combo_step.radius, combo_step.height)
			attack_box_shape.rotation_degrees = combo_step.rotation_offset
	
	# Position and rotate attack box based on direction
	match lastAnimDir:
		"Down":
			attack_box.position = combo_step.offset_down
			attack_box.rotation_degrees = 0
		"Up":
			attack_box.position = combo_step.offset_up
			attack_box.rotation_degrees = 0
		"Right":
			attack_box.position = combo_step.offset_right
			attack_box.rotation_degrees = 90
		"Left":
			attack_box.position = combo_step.offset_left
			attack_box.rotation_degrees = 90
	
	combo_timer.stop()
	attack_box_shape.disabled = false
	# Play the attack animation and add a slight delay to smooth out transitions
	is_attacking = true
	
	match combo_count:
		0: 
			animation.play("attack" + lastAnimDir)
			AudioManager.audio_players["sfx"].stream = sword_woosh1
		1: 
			animation.play("attackReverse"+lastAnimDir)
			AudioManager.audio_players["sfx"].stream = sword_woosh2
			
		2: 
			animation.play("attackThrust"+lastAnimDir)
			AudioManager.audio_players["sfx"].stream = sword_woosh3
			
	AudioManager.audio_players["sfx"].play()
	
	if input_buffered:
		input_buffered = false
		animation.speed_scale = 2
		await get_tree().create_timer(animation.current_animation_length/1.5).timeout
		animation.seek(animation.current_animation_length, true, true)
		await start_attack()  # Execute the next combo step immediately
	else:
		await animation.animation_finished
		animation.speed_scale = 1
		
	
	is_attacking = false
	
	attack_box_shape.disabled = true
	combo_count += 1
	
	# Check the input buffer and execute the next attack if buffered


	if combo_count == len(GameData.skill_passive.combo_steps):
		combo_timer2.start()
		can_attack = false
	else:
		combo_timer.start()
		can_attack = true

	return true

	
	
func _on_combo_timer_timeout():
	var combo_step: ComboStep = GameData.skill_passive.combo_steps[0]
	match combo_step.shape:
		ComboStep.ComboShape.COMBO_CAPSULE:
			attack_box_shape.shape = capsule_shape
			attack_box_shape.shape.radius = combo_step.radius
			attack_box_shape.shape.height = combo_step.height
			attack_box_shape.rotation_degrees = combo_step.rotation_offset
			
		ComboStep.ComboShape.COMBO_CIRCLE:
			attack_box_shape.shape = circle_shape
			attack_box_shape.shape.radius = combo_step.radius
			attack_box_shape.rotation_degrees = combo_step.rotation_offset
		
		ComboStep.ComboShape.COMBO_RECT:
			attack_box_shape.shape = rect_shape
			attack_box_shape.shape.size = Vector2(combo_step.radius, combo_step.height)
			attack_box_shape.rotation_degrees = combo_step.rotation_offset
	
	attack_box_shape.rotation_degrees = 0
	attack_box.position = Vector2(0,0)
	attack_box_shape.disabled = true


func _on_combo_timer_2_timeout():
	attack_box_shape.rotation_degrees = 0
	attack_box.position = Vector2(0,0)
	combo_count = 0
	can_attack = true
	input_buffered = false

func updateAnimation():
	if CutsceneManager.doing_cutscene:
		return
	if is_attacking:
		return
	if is_skilling:
		return
	if doing_skill_1 or doing_skill_2 or doing_skill_3:
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
	handleInput()
	move_and_slide()
	updateAnimation()

func _input(event: InputEvent):
	if CutsceneManager.doing_cutscene:
		return
	if position.y <= viewport_rect.position.y+100:
		player_healthbar.get_parent().set_alpha(true)
	else:
		player_healthbar.get_parent().set_alpha(false)
		

	
	if event.is_action_pressed("interact"):
		var collided_body = look_dir.get_collider()
		if collided_body:
			if collided_body is ItemHolder:
				collided_body.collect()
			elif collided_body is NPC:
				can_talk = false
				match lastAnimDir:
					"Up":
						collided_body.animation_player.play("idleDown")
					"Down":
						collided_body.animation_player.play("idleUp")
					"Left":
						collided_body.animation_player.play("idleRight")
					"Right":
						collided_body.animation_player.play("idleLeft")
		
				await collided_body.animation_player.animation_finished
				collided_body.is_moving = false
				if collided_body.isNPCCanMove:
					collided_body.timer.start(2)
				collided_body.talk()
			
			elif collided_body is Shop:
				collided_body.open_shop()
			
			elif collided_body is Sign:
				collided_body.see_sign()
			
			elif collided_body is MovableObject:
				if not collided_body.is_moving:
					collided_body.move_object(lastAnimDir, moveDir)
					
			elif collided_body is Switch:
				collided_body.change_state()
	
	if event.is_action_pressed("skill_1"):
		if GameData.skill_slot_1:
			GameData.current_skill_equipped = 0

		skill_1._ready()
		skill_2._ready()
		skill_3._ready()

	elif event.is_action_pressed("skill_2"):
		if GameData.skill_slot_2:
			GameData.current_skill_equipped = 1


		skill_1._ready()
		skill_2._ready()
		skill_3._ready()

	elif event.is_action_pressed("skill_3"):
		if GameData.skill_slot_3:
			GameData.current_skill_equipped = 2
			

		skill_1._ready()
		skill_2._ready()
		skill_3._ready()

	if event.is_action_pressed("use_skill") and GameData.weapon_equip != null:
		match GameData.current_skill_equipped:
			0:
				skill_1.do_skill(lastAnimDir)
			1:
				skill_2.do_skill(lastAnimDir)
			2:
				skill_3.do_skill(lastAnimDir)
				
	if event.is_action_pressed("debug"):
		take_damage(100)
func unstun():
	timer.stop()
	is_stunned = false
	is_knocked = false
	drag_force = 0.0

func unHurt():
	hurtTimer.stop()
	is_damaged = false

func knockback(enemyPosition: Vector2, knock_power):
	velocity = Vector2.ZERO
	var knockDir = (enemyPosition.direction_to(position)).normalized() * knock_power
	velocity = knockDir
	move_and_slide()
	is_stunned = true
	is_knocked = true
	timer.start(0.8)
	

func heal(amount:int):
	stats.heal_self(amount)
	player_healthbar._set_amount(stats.hp)

func on_tp_player(coor):
	position = coor


func _on_attack_box_body_entered(body:Node2D):
	if body is Projectile and body.what_skill == SkillTree.Skill_Tree.ENEMY:
		body.velocity = Vector2.ZERO
		body.queue_free()
	if body is Enemy:
		body.damaged(stats.att)
		if not body.is_knocked:
			match lastAnimDir:
				"Up":
					body.knockback(Vector2(0,-1))
				"Down":
					body.knockback(Vector2(0,1))
				"Left":
					body.knockback(Vector2(-1,0))
				"Right":
					body.knockback(Vector2(1,0))

func take_damage(damage):
	if is_damaged and is_stunned: return

	if is_skilling: return

	stats.take_damage(damage)
	player_healthbar.health = stats.hp
	if stats.hp <= 0:
		GameData.do_game_over()
		return
	hurtTimer.start(1)
	is_damaged = true


func quest_trigger(quest_name,type, objective, amn):
	GameData.add_quest(quest_name, type, objective, amn)




func _on_started_cutscene_signal():
	set_physics_process(false)

func _on_finished_cutscene_signal():
	set_physics_process(true)

func status_effect_damage(effect_type: StatusEffect.EffectType,effect_timer:Timer, damage:int  = 0):
	match effect_type:
		StatusEffect.EffectType.EFFECT_POISON:
			stats.take_flat_damage(damage)
			player_healthbar.health = stats.hp
			if stats.hp < 0:
				queue_free()
		StatusEffect.EffectType.EFFECT_STUN:
			is_stunned = true
			await effect_timer.timeout
			is_stunned = false
		StatusEffect.EffectType.EFFECT_SLOW:
			is_slowed = true
			speed = damage
			await effect_timer.timeout
			is_slowed = false
		StatusEffect.EffectType.EFFECT_CONFUSION:
			is_confused = true
			await effect_timer.timeout
			is_confused = false
			
func add_status_effect(effect: Effect):
	var same_effect = status_effects.get_children().filter(func(n): return n.status_effect_type == effect.effect_type)
	if not same_effect:
		var status_effect_node = StatusEffect.new(effect)
		status_effects.add_child(status_effect_node)
		print(status_effect_node.is_stopped())


func _on_hitbox_body_entered(body):
	if body is EntryPoint:
		body.change_map(self)
	if body is Door:
		body.move_to_destination(self)
