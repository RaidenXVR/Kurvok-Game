extends Node2D

class_name World

func _ready():
	CutsceneManager.set_attributes(self)
	CutsceneManager.cutscene_started.connect(_on_cutscene_played)
	CutsceneManager.finished_doing_cutscene.connect(_on_cutscene_finished)
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
	elif  what == NOTIFICATION_UNPAUSED:
		for c: Timer in get_node("StatusTimers").get_children():
			
			c.paused = false
		pass

func _on_cutscene_played():
	#print("cutscene played, gui invisible")
	$CanvasLayer/PlayerHealthBar.visible = false
	$CanvasLayer/ManaBar.visible = false
	$CanvasLayer/MoneyUI.visible = false
	$CanvasLayer/Skill1CD.visible = false
	$CanvasLayer/Skill2CD.visible = false
	$CanvasLayer/Skill3CD.visible = false


func _on_cutscene_finished():
	for canvas in $CanvasLayer.get_children():
		if canvas != self and canvas.name not in ["ShopGUI", "Menu", "Portrait", "Popup", "Dialogue", "Game Over"]:
			canvas.visible = true
