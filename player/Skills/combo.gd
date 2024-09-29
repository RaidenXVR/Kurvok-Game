extends Resource

class_name ComboStep

enum ComboShape {COMBO_CAPSULE, COMBO_CIRCLE, COMBO_RECT}

@export_category("General")
@export var shape: ComboShape
@export var radius: int = 25
@export var height: int = 80
@export var rotation_offset:float
@export var offset_up:Vector2 = Vector2(0,-40)
@export var offset_down:Vector2 = Vector2(0,25)
@export var offset_left:Vector2 = Vector2(-30, -11.5)
@export var offset_right:Vector2 = Vector2(30, -11.5)


