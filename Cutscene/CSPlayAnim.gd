extends Resource

class_name Cutscene_PlayAnimation
enum ObjectAnimType {PLAYER, NPC_OBJ, ENEMY }

@export var object: String
@export var animation_to_play: String
@export var secondary_animation_to_play:String
@export var type: ObjectAnimType
@export var vfx_sprite_scale: Vector2 = Vector2(0.125,0.125)
@export var vfx_z_index: int = -1
@export var parallel_with_next: bool = false


