extends Resource

class_name  Stats

@export var mhp: int
@export var att: int
@export var hp :int = mhp
@export var def: int
@export var max_mana:int
@export var mana:int = max_mana


	
func take_damage(damage:int):
	hp -= (damage-def)

func heal_self(amount:int):
	hp+= amount
	if hp > mhp:
		hp = mhp
	

func do_damage():
	return att

func change_mana(amount):
	mana+=amount

func change_stats(key: String, amount:int):
	if key == "mhp": mhp = mhp+amount
	elif key =="atk": att+=amount
	elif key =="def": def+=amount
	elif key =="max_mana": max_mana+=amount


	