extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterTimer
@onready var lineTimer = $NextLineTimer
const MAX_WIDTH = 256

var text = ""
var letterIdx = 0

var letter_time = 0.03
var space_time = 0.06
var puncuation_time = 0.2

signal finished_displaying()

func display_text(_text:String):
	text = _text
	label.text = _text
	
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # for x
		await resized #for y
		custom_minimum_size.y = size.y
	
	global_position.x -= size.x /2
	global_position.y -= size.y +24
	
	label.text = ""
	_display_letter()
	
	
func _display_letter():
	label.text += text[letterIdx]
	
	letterIdx +=1
	if letterIdx >= text.length():
		finished_displaying.emit()
		return
		
	match text[letterIdx]:
		"!", ".", ",", "?":
			timer.start(puncuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)
	
	
	


func _on_letter_timer_timeout():
	_display_letter()
