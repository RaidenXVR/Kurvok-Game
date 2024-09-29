extends TextureProgressBar

class_name StatusIcon

var icon: Texture2D
var timer_node: Timer
var _time: float
@onready var texture_rect:TextureRect

func _init(status_type:String, timer:Timer, time:float):
	
	match status_type:
		"atk_up":
			icon = load("res://UI/atk_up.png") as Texture2D
		"def_up":
			icon = load("res://UI/def_up.png") as Texture2D
		"mana_up":
			icon = load("res://UI/mana_up.png") as Texture2D
		"atk_down":
			icon = load("res://UI/atk_down.png") as Texture2D
		"def_down":
			icon = load("res://UI/def_down.png") as Texture2D

	texture_rect = TextureRect.new()
	texture_rect.size = Vector2(64,64)
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.custom_minimum_size = Vector2(64,64)
	texture_rect.z_as_relative = true
	texture_rect.z_index = -1
	add_child(texture_rect)
	_time = time
	timer_node = timer
	timer_node.timeout.connect(_buff_timer_timeout)


# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = _time
	value = _time
	min_value = 0
	texture_rect.texture = icon


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value -= delta


func _buff_timer_timeout():
	queue_free()
