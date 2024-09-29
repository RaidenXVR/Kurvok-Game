extends Resource

class_name  Stats

@export var mhp: int = 20
@export var att: int = 5
@export var hp :int = mhp
@export var def: int = 3
@export var max_mana:int = 30
@export var mana:int = max_mana


func take_damage(damage:int):
	if damage > def:
		hp -= (damage-def)
	
	
func take_flat_damage(damage:int):
	hp -= damage

func heal_self(amount:int):
	hp+= amount
	if hp > mhp:
		hp = mhp
	
func use_mana(_mana:int):
	mana -=_mana
func do_damage():
	return att

func change_mana(amount):
	mana+=amount

func change_stats(key: String, amount:int):
	if key == "mhp": mhp = mhp+amount
	elif key =="atk": att+=amount
	elif key =="def": def+=amount
	elif key =="max_mana": max_mana+=amount


	
