extends CharacterBody2D

signal HPChanged
signal is_talking

@export var speed:int=120
@export var maxHP:int = 20
@export var knockPower:int =1000
@export var inventory: Inventory
@export var stats = Stats.new()
@onready var timer = $Timer
@onready var hurtTimer = $hurtTimer
@onready var animation = $AnimationPlayer
@onready var attack_box = $AttackBox
@onready var player_healthbar = get_parent().get_node("CanvasLayer").get_node("PlayerHealthBar")


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
var talk_count: int = 0


func _ready():
	attack_box.monitoring = false
	player_healthbar.init_health(stats.mhp, stats.hp)
	


func handleInput():
	#get input from player
	moveDir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	
	#Looking direction
	if (moveDir.x<0 and velocity.length() == 0 and !is_attacking):
		animation.play("walkLeft")
		animation.stop()
	elif(moveDir.x>0 and velocity.length() == 0 and !is_attacking):
		animation.play("walkRight")
		animation.stop()
	elif (moveDir.y>0 and velocity.length() == 0 and !is_attacking):
		animation.play("walkDown")
		animation.stop()
	elif moveDir.y<0 and velocity.length() == 0 and !is_attacking:
		animation.play("walkUp")
		animation.stop()
		
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
		animation.play("attack"+lastAnimDir)
		is_attacking = true
		is_stunned = true
		attack_box.monitoring = true
		await animation.animation_finished
		attack_box.monitoring = false
		is_stunned = false
		is_attacking = false

func updateAnimation():
	if is_attacking: return
	
	
	if velocity.length() == 0:
		if moveDir == Vector2.ZERO:
			animation.play("walk"+lastAnimDir)
			animation.stop()
		else:
			var dir = "Down"
			if moveDir.x < 0: dir = "Left"
			elif moveDir.x > 0 : dir = "Right"
			elif moveDir.y<0: dir = "Up"
			lastAnimDir = dir
			animation.play("walk"+dir)
			animation.stop()

	else:
		var dir = "Down"
		if velocity.x < 0: dir = "Left"
		elif velocity.x > 0 : dir = "Right"
		elif velocity.y<0: dir = "Up"
		lastAnimDir = dir
		animation.play("walk"+dir)
		
		
func _physics_process(_delta):
	if move_and_slide():
		print("collide")
	handleInput()
	move_and_slide()
	updateAnimation()
	if timer.time_left<0.05 and !timer.is_stopped(): unstun() 
	if hurtTimer.time_left<0.05 and !hurtTimer.is_stopped(): unHurt()


func _on_hitbox_area_entered(area):

	if area.has_method("collect"):
		can_open_chest = true
		temp_area = area
		
	if area.has_method("talk"):
		can_talk = true
		temp_area = area
	
	if area.has_method("open_shop"):
		can_shop = true
		temp_area = area

func _input(event):
	if event.is_action_pressed("interact") and can_open_chest:
		open_chest()
	elif event.is_action_pressed("interact") and can_talk and talk_count<1 and temp_area!=null:
		var facing = -to_local(temp_area.get_parent().position).normalized()
		if facing.x >= facing.y:
			if facing.x >= 0:
				temp_area.get_parent().animation_player.stop()
				temp_area.get_parent().sprite_npc.frame_coords = Vector2(0,3)
				
			else:
				temp_area.get_parent().animation_player.stop()

				temp_area.get_parent().sprite_npc.frame_coords = Vector2(0,1)
				
		else :
			if facing.y >= 0:
				temp_area.get_parent().animation_player.stop()
				temp_area.get_parent().sprite_npc.frame_coords = Vector2(0,2)

			else:
				temp_area.get_parent().animation_player.stop()
				temp_area.get_parent().sprite_npc.frame_coords = Vector2(0,0)
		
		temp_area.get_parent().is_moving = false
		temp_area.get_parent().timer.start(2)
		
		temp_area.talk()
		talk_count = 1
	
	elif event.is_action_pressed("interact") and can_shop and temp_area != null:
		temp_area.open_shop()
	
	if Input.is_action_just_pressed("temp_save"):
		GameData.save_game()
func open_chest():
	if temp_area != null and temp_area.has_method("collect"):
		temp_area.collect(inventory)
		temp_area = null

func unstun():
	timer.stop()
	is_stunned = false

func unHurt():
	hurtTimer.stop()
	is_damaged = false

func knockback(enemyPosition:Vector2):
	var knockDir = (enemyPosition - position).normalized() * knockPower
	velocity = knockDir
	move_and_slide()
	is_stunned = true
	
	timer.start(0.8)
	

func heal(amount:int):
	stats.heal_self(amount)
	HPChanged.emit(amount)
	player_healthbar._set_health(stats.hp)

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
	if area.name == "Hitbox":
		area.get_parent().damaged(stats.do_damage())

		

func take_damage(damage):
	if is_damaged: return
	if is_stunned: return
	stats.take_damage(damage)
	player_healthbar.health = stats.hp
	if stats.hp < 0:
		stats.hp = maxHP
	HPChanged.emit(stats.hp)
	hurtTimer.start(1)
	is_damaged = true

func quest_trigger(quest_name,type, objective, amn):
	GameData.add_quest(quest_name, type, objective, amn)

