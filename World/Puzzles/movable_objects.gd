extends CharacterBody2D

class_name MovableObject

@export var texture: Texture2D
@export var speed: float
var move_dir: Vector2
var destination: Vector2
var is_moving = false
func _ready():
	$Sprite2D.texture = texture

func _process(_delta):
	if position.distance_to(destination)> 0.5 and is_moving:
		var col = move_and_collide(move_dir*0.2)
		if col:
			is_moving = false
			destination = Vector2.ZERO
			velocity = Vector2.ZERO
	else:
		is_moving = false
		velocity = Vector2.ZERO

func move_object(dir:String, vector_dir:Vector2):
	if vector_dir == Vector2.ZERO:
		match dir:
			"Up":
				move_dir = Vector2(0,-1)
			"Down":
				move_dir = Vector2(0,1)
			"Left":
				move_dir = Vector2(-1,0)
			"Right":
				move_dir = Vector2(1,0)
	
	elif vector_dir != Vector2.ZERO and vector_dir.abs().ceil() != Vector2(1,1):
		move_dir = vector_dir
	else:
		return
	destination = position + (move_dir*GameData.tile_size)
	is_moving = true

	
