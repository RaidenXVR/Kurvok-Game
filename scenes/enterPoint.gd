extends Area2D
signal map_change(map_name)

@export var currentMap: TileMap
@export var destiMap: TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	# connect("body_entered", _on_body_entered)
	pass

func changeMap():
	if self.name == "westPoint":
		connect("map_change", get_node("/root/World/maps")._on_west_point_map_change)
	elif self.name == "eastPoint":
		connect("map_change", get_node("/root/World/maps")._on_east_point_map_change)

	emit_signal("map_change", get_parent().get_parent().name)
	
	if self.name == "westPoint":
		disconnect("map_change", get_node("/root/World/maps")._on_west_point_map_change)
	elif self.name == "eastPoint":
		disconnect("map_change", get_node("/root/World/maps")._on_east_point_map_change)

	
	
func deactivate_area(child: Area2D):
	child.monitoring = false
	child.get_node("shape").disabled = true
func activate_deactivate_area(node: Node2D):
	if not node.is_visible():
		for child in node.get_children(true):
			if child is Area2D:
				child.get_node("shape").disabled = true
	else:
		for child in node.get_children(true):
			if child is Area2D:
				child.get_node("shape").disabled = false
	
func _on_body_entered(body):
	if body.name == "Player":
		pass
		# changeMap()
		
