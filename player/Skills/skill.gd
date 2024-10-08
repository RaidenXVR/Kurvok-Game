extends Node2D
@export_group("General Skill Settings")
@export var skill_name: String
@export var skill_icon: Texture2D
@export var skill_category: Skill.SkillCategory
@export var skill_type: SkillTree.Skill_Tree
@export var skill_shape:Skill.SkillShape
@export var cooldown: float
@export var shape_size: Vector2
@export var force: int = 300
@export var skill_stun_duration: float = 0.2
@export var skill_description:String
@export var mana_consumption: int
@export var inflicted_status_effect: Effect
@export var damage_mod:int
@export var animation_name:String
@export var is_directional_animation: bool
@export var vfx_animation_name: String
@export var vfx_scale: float = 1

@export_group("Skill Move")
@export var is_reverse: bool
@export var offset_up:Vector2
@export var offset_down:Vector2
@export var offset_left:Vector2
@export var offset_right:Vector2

@export_group("Skill Projectile")
@export var projectiles_count:int = 1
@export var is_full_circle_division:bool
@export var projectile_res: ProjectileSettings

@export_group("Skill Area")
@export var is_variable_size: bool
@export var duration_variable_size: float
@export var max_radius: int
@export var min_radius: int

@export_group("Skill Passive/Combo")
@export var combo_steps: Array[ComboStep]

@onready var attack_box_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var attack_box:Area2D = $Area2D
@onready var skilling_timer:Timer = $SkillingTimer
@onready var skill_cd:Timer = $SkillCD
var skill_cd_gui: TextureProgressBar

var player:Player
var can_skill = true
var is_skilling = false
var drag_force = 0
var vel
var index

var circle_shape = CircleShape2D.new()
var capsule_shape = CapsuleShape2D.new()
var cd_gui_0 = preload("res://asset/CD_frame0.png")
var cd_gui_1 = preload("res://asset/CD_frame1.png")

func _ready():
	player = get_parent().get_parent()
	if not GameData.equip_skill_change.is_connected(_ready):
		GameData.equip_skill_change.connect(_ready)
	index = get_index()
	var skill_slot:Skill
	match index:
		0:
			skill_slot = GameData.skill_slot_1
			skill_cd_gui = get_node("/root/World/CanvasLayer/Skill1CD")
			
		1: 
			skill_slot = GameData.skill_slot_2
			skill_cd_gui = get_node("/root/World/CanvasLayer/Skill2CD")
		2:
			skill_slot = GameData.skill_slot_3
			skill_cd_gui = get_node("/root/World/CanvasLayer/Skill3CD")

	if GameData.current_skill_equipped == index:
		skill_cd_gui.texture_over = cd_gui_1
	else:
		skill_cd_gui.texture_over = cd_gui_0
	
	if skill_slot:
		skill_name = skill_slot.skill_name
		skill_icon = skill_slot.icon
		skill_category = skill_slot.skill_category
		skill_shape = skill_slot.skill_shape
		skill_type = skill_slot.skill_type
		cooldown = skill_slot.cooldown
		shape_size = skill_slot.shape_size
		force = skill_slot.force
		skill_stun_duration = skill_slot.skill_stun_duration
		is_full_circle_division = skill_slot.is_full_circle_division
		skill_description = skill_slot.skill_description
		mana_consumption = skill_slot.mana_consumption
		damage_mod = skill_slot.damage_mod
		animation_name = skill_slot.animation_name
		is_directional_animation = skill_slot.is_directional_animation
		vfx_animation_name = skill_slot.vfx_animation_name
		vfx_scale = skill_slot.vfx_scale
		
		is_reverse = skill_slot.is_reverse
		offset_up = skill_slot.offset_up
		offset_down = skill_slot.offset_down
		offset_left = skill_slot.offset_left
		offset_right = skill_slot.offset_right
		
		projectiles_count = skill_slot.projectiles_count
		is_full_circle_division = skill_slot.is_full_circle_division
		projectile_res = skill_slot.projectile_res
		
		is_variable_size = skill_slot.is_variable_size
		duration_variable_size = skill_slot.duration_variable_size
		max_radius = skill_slot.max_radius
		min_radius = skill_slot.min_radius
		skill_cd_gui.texture_under = skill_icon
	else:
		skill_name = ""
		skill_icon = null
		
		@warning_ignore("int_as_enum_without_match")
		@warning_ignore("int_as_enum_without_cast")
		skill_category = -1
		
		@warning_ignore("int_as_enum_without_match")
		@warning_ignore("int_as_enum_without_cast")
		skill_shape = -1
		
		@warning_ignore("int_as_enum_without_match")
		@warning_ignore("int_as_enum_without_cast")
		skill_type = -1
		cooldown = -1
		shape_size = Vector2()
		force = -1
		skill_stun_duration = -1
		is_full_circle_division = false
		skill_description = ""
		mana_consumption = -1
		
		is_reverse = false
		offset_up = Vector2()
		offset_down = Vector2()
		offset_left = Vector2()
		offset_right = Vector2()
		
		projectiles_count = -1
		is_full_circle_division = false
		projectile_res = null
		
		is_variable_size = false
		duration_variable_size = -1
		max_radius = -1
		min_radius = -1
		skill_cd_gui.texture_under = null

func _process(_delta):
	if skill_category == Skill.SkillCategory.SKILL_MOVE:
		if !can_skill:
			skill_cd_gui.value = snapped(skill_cd.time_left,0.1)
		if is_skilling:
			if skilling_timer.time_left > 0.001:
				player.velocity = vel
				drag_force += 0.1

			else:
				if drag_force >1:
					drag_force = 1
				player.velocity = vel - (vel*drag_force)
				drag_force += 0.1

			player.move_and_slide()

	else:
		if !can_skill:
			skill_cd_gui.value = snapped(skill_cd.time_left,0.1)

func do_skill(lastAnimDir):
	match skill_category:
		Skill.SkillCategory.SKILL_MOVE:
			skill_move(lastAnimDir)
		Skill.SkillCategory.SKILL_PROJECTILE:
			skill_projectile(lastAnimDir)
		Skill.SkillCategory.SKILL_AREA:
			skill_area()


func skill_move(lastAnimDir):
	if can_skill and player.stats.mana >= mana_consumption:
		drag_force = 0
		can_skill = false
		player.doing_skill_1 = true
		if is_directional_animation:
			player.animation.play(animation_name+lastAnimDir)
		else:
			player.animation.play(animation_name)
		
		#await  player.animation.animation_finished
		
		var shape
		if skill_shape == Skill.SkillShape.SHAPE_CIRCLE:
			shape = circle_shape
			shape.radius = shape_size.x
		else:
			shape = capsule_shape
			shape.radius = shape_size.x
			shape.height = shape_size.y
			
		if is_reverse:
			match lastAnimDir:
				"Down":
					lastAnimDir = "Up"
				"Up":
					lastAnimDir = "Down"
				"Left":
					lastAnimDir = "Right"
				"Right":
					lastAnimDir = "Left"
		
		attack_box_shape.shape = shape
		
		match lastAnimDir:
			"Down":
				player.velocity = Vector2(0,1) * force 
				attack_box_shape.position = Vector2(0,15)
				attack_box_shape.rotation_degrees = 0

			"Up": 
				player.velocity  = Vector2(0,-1) * force
				attack_box_shape.position = Vector2(0,-60)
				attack_box_shape.rotation_degrees = 0

			"Left": 
				player.velocity = Vector2(-1,0)*force 
				attack_box_shape.position = Vector2(-35,-20)
				attack_box_shape.rotation_degrees = 90


			"Right": 
				player.velocity = Vector2(1,0)* force 
				attack_box_shape.position =  Vector2(35,-20)
				attack_box_shape.rotation_degrees = 90
		

			


		vel = player.velocity
		attack_box.monitoring = true
		attack_box_shape.disabled = false
		player.is_immune = true
		skilling_timer.start(skill_stun_duration)
		skill_cd.start(cooldown)
		player.stats.use_mana(mana_consumption)
		player.manabar._set_amount(player.stats.mana)
		skill_cd_gui.max_value = cooldown
		skill_cd_gui.texture_over = cd_gui_0
		is_skilling = true
		


func skill_projectile(lastAnimDir):
	if can_skill and player.stats.mana >= mana_consumption:
		#player.animation.stop()
		#player.animation.animation_finished.emit()
		player.doing_skill_2 = true
		if is_directional_animation:
			player.animation.play(animation_name+lastAnimDir)
		else:
			player.animation.play(animation_name)
		
		await player.animation.animation_finished
		
		var skill_pos = player.position
		var shoot_dir
		#projectile_offset.x -= (5*(projectiles_count/2)) 
		match lastAnimDir:
			"Down":
				shoot_dir = Vector2(0,1)

			"Up":
				shoot_dir = Vector2(0,-1)

			"Left":
				shoot_dir = Vector2(-1,0)

			"Right":
				shoot_dir = Vector2(1,0)
		
		if projectiles_count % 2 == 0:
		# Ensure that num_projectiles is odd, add 1 if it's even.
			projectiles_count += 1
		
		var angle_step = 180.0 / (projectiles_count)
		if is_full_circle_division:
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
			#force is speed
			projectile.init(player.stats.att,shoot_dirs[i],skill_pos,projectile_res)
			get_node("/root/World").add_child(projectile)
		
		skill_cd.start(cooldown)
		skilling_timer.start(skill_stun_duration)
		player.velocity = Vector2.ZERO
		can_skill = false
		player.is_stunned = true
		is_skilling = true
		skill_cd_gui.texture_over = cd_gui_0
		skill_cd_gui.max_value = cooldown
		player.stats.use_mana(mana_consumption)
		player.manabar._set_amount(player.stats.mana)

func skill_area() :#AOE
	if is_variable_size:
		if can_skill and player.stats.mana >= mana_consumption:
			var tween = get_tree().create_tween()
			can_skill = false
			player.animation.play("magicDown")
			match skill_shape:
				Skill.SkillShape.SHAPE_CIRCLE:
					attack_box_shape.shape = circle_shape
				Skill.SkillShape.SHAPE_CAPSULE:
					attack_box_shape.shape = capsule_shape
			attack_box_shape.disabled = false
			attack_box.monitoring = true
			player.velocity = Vector2.ZERO
			player.doing_skill_3 = true
			skill_cd_gui.texture_over = cd_gui_0
			skill_cd_gui.max_value = cooldown
			skilling_timer.start(skill_stun_duration)
			tween.tween_property(attack_box_shape.shape.radius, "radius", max_radius, duration_variable_size).from(min_radius)
			tween.tween_callback(func():_on_area_tween_finished(tween))
			player.stats.use_mana(mana_consumption)
			player.manabar._set_amount(player.stats.mana)
			
			

	else:
		if can_skill and player.stats.mana >= mana_consumption:
			player.animation.play("magicDown")
			player.doing_skill_3 = true
			player.velocity = Vector2.ZERO
			player.vfx_node.scale = Vector2(0.25,0.25)
			player.vfx_node.visible = true
			player.vfx_node.play("BlueMC")
			await player.animation.animation_finished
			player.vfx_node.visible = false

			
			is_skilling = true
			player.vfx_node.scale = Vector2(vfx_scale, vfx_scale)
			player.vfx_node.visible = true
			player.vfx_node.play(vfx_animation_name)
			match skill_shape:
				Skill.SkillShape.SHAPE_CIRCLE:
					attack_box_shape.shape = circle_shape
				Skill.SkillShape.SHAPE_CAPSULE:
					attack_box_shape.shape = capsule_shape
			attack_box_shape.shape.radius = max_radius
			can_skill = false
			attack_box_shape.disabled = false
			attack_box.monitoring = true
			skill_cd_gui.texture_over = cd_gui_0
			skill_cd_gui.max_value = cooldown
			skilling_timer.start(skill_stun_duration)
			skill_cd.start(cooldown)
			player.stats.use_mana(mana_consumption)
			player.manabar._set_amount(player.stats.mana)

func _on_area_tween_finished(tween:Tween):
	skill_cd.start(cooldown)
	tween.kill()

func _on_skilling_timer_timeout():
	if skill_category == Skill.SkillCategory.SKILL_MOVE:
		is_skilling = false
		
		attack_box_shape.shape.radius = 20
		attack_box_shape.position = Vector2(0,0)
		attack_box_shape.rotation_degrees = 0
		attack_box.monitoring = false

		attack_box_shape.disabled = true
		await player.animation.animation_finished
		player.doing_skill_1 = false
	
	elif skill_category == Skill.SkillCategory.SKILL_PROJECTILE:
		is_skilling = false
		player.is_stunned = false
		player.doing_skill_2 = false
	
	elif skill_category == Skill.SkillCategory.SKILL_AREA:
		if not is_variable_size:
			is_skilling = false
			player.doing_skill_3 = false
			attack_box_shape.disabled = true
			attack_box.monitoring = false
			player.vfx_node.visible = false
			player.vfx_node.scale = Vector2.ZERO
			
	player.is_immune = false

func _on_skill_timer_timeout():
	can_skill = true
	skill_cd_gui.texture_over = cd_gui_1

func _on_attack_box_body_entered(body:Node2D):
	if body is Projectile and body.from_enemy:
		body.velocity = Vector2.ZERO
		body.queue_free()
	if body is Enemy:
		var bonus_attack = SkillTree.get_properties(skill_type)["bonus_atk"]
		body.damaged(player.stats.att + bonus_attack)

func change_type(replacer_skill:Skill):
	match index:
		0:GameData.skill_slot_1 = replacer_skill
		1:GameData.skill_slot_2 = replacer_skill
		2: GameData.skill_slot_3 = replacer_skill
	_ready()
