extends Timer

class_name StatusEffect

enum EffectType {EFFECT_STUN, EFFECT_SLOW, EFFECT_CONFUSION, EFFECT_POISON}

@onready var parent_body = get_parent().get_parent()
var secondary_timer: Timer = Timer.new()

var status_effect_type: EffectType
var damage: int

func _ready():
	add_child(secondary_timer)
	_on_tick_timeout()

func _init(effect:Effect):
	
	autostart = true
	one_shot = true
	timeout.connect(_on_duration_timeout)
	secondary_timer.timeout.connect(_on_tick_timeout)
	status_effect_type = effect.effect_type
	damage = effect.damage_or_modifier
	wait_time = effect.duration
	if effect.tick_duration != 0:
		secondary_timer.wait_time = effect.tick_duration
		secondary_timer.autostart = true
		secondary_timer.one_shot = false
	

func _on_duration_timeout():
	stop()
	secondary_timer.stop()
	queue_free()

func _on_tick_timeout():
	parent_body.status_effect_damage(status_effect_type,self,damage)

