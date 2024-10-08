extends Resource

class_name Skill

enum SkillCategory {SKILL_MOVE, SKILL_PROJECTILE, SKILL_AREA, SKILL_PASSIVE}
enum SkillShape {SHAPE_CIRCLE, SHAPE_CAPSULE}

@export_group("General Skill Settings")
@export var skill_name: String
@export var icon:Texture2D
@export var skill_category: Skill.SkillCategory
@export var skill_type: SkillTree.Skill_Tree
@export var skill_shape:Skill.SkillShape
@export var cooldown: float
@export var shape_size: Vector2
@export var force: int = 300
@export var skill_stun_duration: float = 0.2
@export var skill_description:String
@export var mana_consumption:int
@export var damage_mod: int
@export var animation_name:String
@export var is_directional_animation: bool
@export var vfx_animation_name: String
@export var vfx_scale:float = 1

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

