extends Resource

class_name EnemyAttack

enum EnemyAttackType {ENEMY_TOUCH, ENEMY_SLASH, ENEMY_SHOOT,ENEMY_MULTISHOT, ENEMY_AREA}

@export_category("General")
@export var attack_type: EnemyAttackType
@export var effect: Effect
@export var speed_mod:int
@export var stun_duration:float
@export var shape_radius:int

@export_category("Projectile")
@export var num_projectile:int
@export var is_full_circle_division: bool
@export var projectile_res: ProjectileSettings

@export_category("Area")
@export var distance_for_aoe: int

@export_category("Slash")
@export var distance_for_slash: int
@export var slash_shape_offset: int


