extends Button

signal choice(key:String, special_key:String)
@export var option_text:String = ""
@export var special_var: String = ""



func update_text():
	text = option_text
func connect_func():
	connect("choice", get_parent().get_parent()._chosen_option)
	
func _on_button_pressed():
	emit_signal("choice", text, special_var)


