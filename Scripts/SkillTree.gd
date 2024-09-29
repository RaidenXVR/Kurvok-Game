extends Node

enum Skill_Tree{LIGHTNING, WIND, WATER, ENEMY}


func get_properties(state:Skill_Tree):
	if state == Skill_Tree.LIGHTNING:
		return {"animation": ["LProjectile", "LProjectileEx"],"bonus_atk": 5, "combo_count": 3}
	elif state == Skill_Tree.WIND:
		return {"animation": ["LProjectile", "LProjectileEx"],"bonus_atk": 5}
	elif state == Skill_Tree.WIND:
		return {"animation": ["LProjectile", "LProjectileEx"],"bonus_atk": 5}
	elif state == Skill_Tree.ENEMY:
		return {"animation": ["LProjectile", "LProjectileEx"],"bonus_atk": 5}

