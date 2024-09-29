extends Resource
class_name ProjectileSettings

@export var projectile_speed: int = 100
@export var pro_anim_offset: Vector2 = Vector2(0, 0)
@export var projectile_radius: int = 10
@export var state: SkillTree.Skill_Tree = SkillTree.Skill_Tree.LIGHTNING
@export var effect: Effect = null
