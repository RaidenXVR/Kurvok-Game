extends ProgressBar


@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health = 0 : set= _set_amount

func init_amount(mhp, hp):
	health = hp
	max_value = mhp
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

func _set_amount(new_health):
	var prev_hp = health
	health = min(max_value, new_health)
	value = health

	if health < prev_hp:
		timer.start()
	else:
		damage_bar.value = health

func _on_timer_timeout():
	damage_bar.value = health
	pass # Replace with function body.
