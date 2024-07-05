extends Area2D



@export var items:Array[Vector2]
@export var is_opened: bool = false
@onready var anim: AnimationPlayer = get_parent().get_node("AnimationPlayer")
@export var chest_name: String



	
