extends Resource

class_name EnemyData

@export var enemy_type: String
@export var enemy_stats: Stats
@export var speed:int = 30
@export var knockPower:int = 300
@export var detect_radius:int = 200
@export var col_hitbox_radius: int = 15
@export var move_delay: float
@export var move_pattern: Array[Dictionary]
@export var attack_radius:int = 20
@export var attack_delay: float = 2
@export var attack_patterns: Array[EnemyAttack]
@export var default_shape_radius: int
@export var enemy_sprite_frames: SpriteFrames
