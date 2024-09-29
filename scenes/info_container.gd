extends VBoxContainer


signal can_do_tween

func _ready():
	GameData.player_inventory.item_get.connect(show_info)

func show_info(text_string:String):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2,0.2,0.2, 0.4)
	style.set_border_width_all(3)
	style.border_color = Color(0.1,0.1,0.1,1)
	
	var label = Label.new()

	
	label.size.y = 50
	label.text = text_string
	label.add_theme_font_size_override("font_size", 25)
	label.add_theme_color_override("font_color", Color(1,1,1,1))
	label.add_theme_stylebox_override("normal", style)
	create_anim(label)
	


func create_anim(label:Label):
	var children_count = get_child_count()
	var start_pos = Vector2(150,label.position.y+(children_count*50))
	var wait_pos = Vector2(label.position.x, label.position.y+(children_count*50))
	var end_pos = Vector2(label.position.x, -100)
	var tween = get_tree().create_tween()
	tween.step_finished.connect(_can_tween)
	tween.tween_property(label,"position", wait_pos, 0.2).from(start_pos).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", wait_pos,1.2).from(wait_pos)
	tween.tween_property(label, "position", end_pos, 0.2).from(wait_pos).set_ease(Tween.EASE_OUT_IN)
	tween.tween_callback(func(): label.queue_free();tween.kill())
	
	if children_count == 0:
		add_child(label)
		tween.play()
	else:
		tween.stop()
		await can_do_tween
		add_child(label)
		tween.play()


func _can_tween(step):
	if step == 0:
		can_do_tween.emit()

	
func debug(args):
	print(args)
