extends CharacterBody2D

class_name Projectile

var projectile_speed = 200

var animation_name: Array
var pro_offset: Vector2
var damage_to_deal:int
var pro_velocity: Vector2
var anim_player:AnimatedSprite2D
var what_skill
var is_explode: bool = false
var _effect:Effect



@onready var projectile_shape: CollisionShape2D = $ProjectileShape

func _ready():
	anim_player.speed_scale = anim_player.sprite_frames.get_frame_count(animation_name[0]) * 2
	anim_player.offset = pro_offset
	anim_player.play(animation_name[0])
	# velocity = pro_velocity * projectile_speed
	# move_and_collide(pro_velocity*projectile_speed)


func init(damage: int, pro_direct: Vector2, parent_pos: Vector2, settings: ProjectileSettings):
	var properties = SkillTree.get_properties(settings.state)

	_effect = settings.effect
	what_skill = settings.state
	animation_name = properties["animation"]
	position = parent_pos + pro_direct * 30

	projectile_speed = settings.projectile_speed
	pro_offset = settings.pro_anim_offset
	damage_to_deal = damage
	anim_player = get_node("ProjectileSprite") as AnimatedSprite2D

	if settings.state == SkillTree.Skill_Tree.ENEMY:
		collision_layer = 64
		collision_mask = 32
	else:
		collision_layer = 32
		collision_mask = 64

	pro_velocity = pro_direct
	anim_player.rotation = Vector2(1, 0).angle_to(pro_direct)





func _physics_process(delta):
	
	var coli = move_and_collide(pro_velocity*delta*projectile_speed)

	if coli:
		queue_free()
		var col = coli.get_collider()
		pro_velocity = Vector2.ZERO
		anim_player.offset = Vector2.ZERO
		anim_player.play(animation_name[1])
		if col is Enemy and !what_skill == SkillTree.Skill_Tree.ENEMY:
			col.damaged(damage_to_deal)
			col.knockback(global_position,200)
			col.add_status_effect(_effect)
			
		if col is Player and what_skill == SkillTree.Skill_Tree.ENEMY:
			col.take_damage(damage_to_deal)
			col.knockback(global_position)
			col.add_status_effect(_effect)

		await anim_player.animation_finished
		anim_player.scale = Vector2(1,1)




func _on_water_skill_explode():
	var area = Area2D.new()
	var explosion_shape = CollisionShape2D.new()
	explosion_shape.shape = CircleShape2D.new()
	explosion_shape.shape.radius = 100
	area.collision_mask = 48
	anim_player.scale = Vector2(6,6)
	area.add_child(explosion_shape)
	add_child(area)
	area.connect("body_entered", _on_explode)

func _on_explode(body:Node2D):
	if body is Enemy:
		@warning_ignore("integer_division")
		body.damaged(damage_to_deal/2)
		body.knockback(global_position)


	

