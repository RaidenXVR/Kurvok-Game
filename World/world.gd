extends Node2D

class_name World

func _ready():
	CutsceneManager.set_attributes(self)
	# GameData.player_inventory.updated.emit()

func _on_menu_opened():
	get_tree().paused = true

func _on_menu_closed():
	get_tree().paused = false

func do_pop_up(text:String):
	var popup_node = get_node("CanvasLayer/Popup")
	var popup_label_node = get_node("CanvasLayer/Popup/Label")
	var timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout",func():_popup_timer_timeout(timer))
	popup_label_node.text = text
	popup_node.visible = true
	add_child(timer)
	timer.start(3)


func _popup_timer_timeout(timer:Timer):
	var popup_node = get_node("CanvasLayer/Popup")
	popup_node.visible = false
	timer.queue_free()

func _notification(what):
	if what == NOTIFICATION_PAUSED:
		for c: Timer in get_node("StatusTimers").get_children():
			c.paused = true
			print("paused")
	elif  what == NOTIFICATION_UNPAUSED:
		for c: Timer in get_node("StatusTimers").get_children():
			
			c.paused = false
		pass
