extends Node


@onready var textbox_scene = preload("res://textbox/text_box.tscn")
signal is_finished_talking

var dialog_lines: Array[String] = []
var current_line_idx = 0

var textbox
var textbox_position: Vector2
var lineTimer: Timer = Timer.new()
var timer = 1

var is_dialog_active = false
var can_advance_line = false

func _process(delta):
	if !textbox == null:
		if (timer <=0 &&
		is_dialog_active &&
		can_advance_line 
		):
			timer = 1
			print("queue free textbox")
			textbox.queue_free()
			current_line_idx +=1
			if current_line_idx >= dialog_lines.size():
				is_dialog_active = false
				current_line_idx = 0
				
				return
			
			_show_text_box()
	timer -= delta

func start_dialog(position: Vector2, lines: Array[String]):
	if is_dialog_active:
		return
	dialog_lines = lines
	textbox_position = position
	_show_text_box()
	
	is_dialog_active = true

func _show_text_box():
	textbox = textbox_scene.instantiate()
	textbox.finished_displaying.connect(_on_textbox_finished_displaying)
	get_tree().root.add_child(textbox)

	textbox.global_position = textbox_position
	if !dialog_lines.is_empty():
		textbox.display_text(dialog_lines[current_line_idx])
	can_advance_line = false

func _on_textbox_finished_displaying():
	can_advance_line = true


func _unhandled_input(event):
	if (event.is_action_pressed("interact") &&
	is_dialog_active &&
	can_advance_line 
	):
		print("queue free textbox")
		textbox.queue_free()
		current_line_idx +=1
		if current_line_idx >= dialog_lines.size():
			is_dialog_active = false
			current_line_idx = 0
			
			return
		
		_show_text_box()
		

