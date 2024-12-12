extends TextureProgressBar

class_name StatusIcon

var icon: Texture2D
var timer_node: Timer
var _time: float
var texture_rect:TextureRect
var gradient: GradientTexture2D

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
	
	gradient = GradientTexture2D.new()
	gradient.gradient = Gradient.new()
	gradient.gradient.colors =  PackedColorArray([Color(0.47,0.47,0.95,0.56), Color(0.23,0.23,0.88,0.40)])
	texture_rect = TextureRect.new()
	texture_rect.size = Vector2(64,64)
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	texture_rect.custom_minimum_size = Vector2(64,64)
	texture_rect.z_as_relative = true
	texture_rect.z_index = -1
	texture_rect.anchors_preset = TextureRect.PRESET_FULL_RECT
	_time = time
	timer_node = timer
	timer_node.timeout.connect(_buff_timer_timeout)


# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2(64,64)
	max_value = timer_node.wait_time
	value = timer_node.wait_time
	min_value = 0
	print(max_value, value)
	fill_mode = TextureProgressBar.FILL_COUNTER_CLOCKWISE
	rounded = true
	step = 1
	texture_progress = gradient
	add_child(texture_rect)
	texture_rect.texture = icon
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	value = timer_node.time_left

func _buff_timer_timeout():
	queue_free()
