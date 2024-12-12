extends Node2D


# Called when the node enters the scene tree for the first time.

func button_pressed():
	var tent = load("res://Enemies/enemies/tentacle.tres") as EnemyData
	var items = []
	for item in tent.drop_table:
		var r = randf()
		if r < tent.drop_table[item]["chance"]:
			#var ran = [range(tent.drop_table[item]["min_amount"], tent.drop_table[item]["max_amount"])]
			var weights = []
			for i in range(tent.drop_table[item]["min_amount"], tent.drop_table[item]["max_amount"]+1): weights.append({str(i):float(1.0/i)})
			r = randf()
			#print(weights)
			var amount = weights.filter(func(x): return  r < x[x.keys()[0]] )[-1].keys()[0]
			items.append({item: int(amount)})
	
	print(items)



