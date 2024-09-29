extends StaticBody2D

class_name Door

@export var map_destination:String
@export var door_destination:String
enum OutOffset {OFFSET_UP, OFFSET_DOWN, OFFSET_LEFT, OFFSET_RIGHT}
@export var out_offset: OutOffset
@export var is_double_door: bool
@onready var sprite_anim_door1 = $CollisionShape2D/AnimatedSprite2D
@onready var sprite_anim_door2 = $CollisionShape2D2/AnimatedSprite2D

var finished_moving = true

func _ready():
	if is_double_door:
		get_child(1).visible = true
	
	else:
		get_child(1).visible = false
		get_child(1).shape.disabled = true
	pass


func move_to_destination(player_body:Player):
	var load_map = load("res://map/"+map_destination+".tscn")
	var map: TileMap
	if load_map:
		map = load_map.instantiate()
		var door = map.get_node("Doors/"+door_destination) as Door
		
		if door:
			player_body.set_process_input(false)
			player_body.set_physics_process(false)
			finished_moving = false
			sprite_anim_door1.play("open")
			sprite_anim_door2.play("closed")
			await sprite_anim_door2.animation_finished
			#sprite_anim_door1.stop()
			#sprite_anim_door2.stop()
			
			var tween = get_tree().create_tween()
			match player_body.lastAnimDir:
				"Up":
					player_body.animation.play("walkUp")
					tween.tween_property(player_body,"position", Vector2(player_body.position.x, player_body.position.y-24), 0.5)
					#tween.tween_callback(func():_on_finish_tween(player_body, tween))
					#tween.play()
				"Down":
					player_body.animation.play("walkDown")
					tween.tween_property(player_body,"position", Vector2(player_body.position.x, player_body.position.y+24), 0.5)
					#tween.tween_callback(func():_on_finish_tween(player_body, tween))
					#tween.play()
				"Left":
					player_body.animation.play("walkLeft")
					tween.tween_property(player_body,"position", Vector2(player_body.position.x-24, player_body.position.y), 0.5)
					#tween.tween_callback(func():_on_finish_tween(player_body, tween))
					#tween.play()
				"Right":
					player_body.animation.play("walkRight")
					tween.tween_property(player_body,"position", Vector2(player_body.position.x+24, player_body.position.y), 0.5)
					#tween.play()
			
			tween.tween_callback(func():_on_finish_tween(player_body, tween))
			await tween.finished
			tween.stop()
			player_body.animation.stop()
			print("tween finished")
			match door.out_offset:
				0:
					player_body.position = Vector2(door.position.x, door.position.y-48)
					print("out up")
				1:
					player_body.position = Vector2(door.position.x, door.position.y+48)
				2:
					player_body.position = Vector2(door.position.x-48, door.position.y)
				3:
					player_body.position = Vector2(door.position.x+48, door.position.y)
			get_node("/root/World/maps").add_child(map)
			get_parent().get_parent().queue_free()
		

func _on_finish_tween(player_node:Player, tween: Tween):
	player_node.set_process_input(true)
	player_node.set_physics_process(true)
	print("on finish tween")
	print(player_node.is_physics_processing())
	finished_moving = true
	tween.kill()

func debug():
	print("anim finished")
