extends Node2D

var can_skill = true
var player:Player

var skill_state = SkillTree.Skill_Tree.LIGHTNING
var circle_shape = CircleShape2D.new()
var layer_circle
var is_lightning = false
var is_water = false
var is_wind = false
var winding = false
var water_multipler = 0
var last_torus_size = Vector2(25,50)
var glo_pos
var equipped = false

@onready var attack_box = $AttackBox
@onready var attack_box_shape = $AttackBox/CollisionShape2D
@onready var attack_box_polygon = $AttackBox/CollisionPolygon2D
@onready var skilling_timer = $SkillingTimer
@onready var skill_cd = $SkillTimer
@onready var skill_3_cd_gui = get_node("/root/World/CanvasLayer/Skill3CD")

var cd_gui_0 = preload("res://asset/CD_frame0.png")
var cd_gui_1 = preload("res://asset/CD_frame1.png")

func _ready():
	if GameData.current_skill_equipped == 3:
		skill_3_cd_gui.texture_over = cd_gui_1
	else:
		skill_3_cd_gui.texture_over = cd_gui_0


func _process(_delta):
	if !can_skill:
		skill_3_cd_gui.value = snapped(skill_cd.time_left,0.1)
	if !can_skill and is_water:
		attack_box.global_position = glo_pos


func cast_skill(state:SkillTree.Skill_Tree):
	player = get_parent()
	skill_state = state
	if state == SkillTree.Skill_Tree.LIGHTNING:
		lightning_burst()
	elif state == SkillTree.Skill_Tree.WATER:
		aqua_surge()
	elif state == SkillTree.Skill_Tree.WIND:
		cyclone_barrier()



func lightning_burst() :#AOE
	if can_skill:
		attack_box_shape.shape.radius = 150
		can_skill = false
		attack_box_shape.disabled = false
		attack_box_polygon.disabled = true
		attack_box.monitoring = true
		player.velocity = Vector2.ZERO
		player.doing_skill_3 = true
		skill_3_cd_gui.texture_over = cd_gui_0
		skill_3_cd_gui.max_value = 5
		is_lightning = true
		skilling_timer.start(0.5)
		skill_cd.start(5)


func cyclone_barrier():
	if can_skill:
		attack_box_polygon.polygon = torus_points(50,75)
		is_wind = true
		attack_box_polygon.disabled = false
		attack_box_shape.disabled = true
		attack_box.monitoring = true
		player.velocity = Vector2.ZERO
		can_skill = false
		skill_3_cd_gui.texture_over = cd_gui_0
		skill_3_cd_gui.max_value = 5
		skilling_timer.start(0.5)
		skill_cd.start(5)


func aqua_surge():
	if can_skill:
		attack_box_polygon.polygon = torus_points(25,50)
		is_water = true
		var pos = player.global_position
		glo_pos = pos
		attack_box.global_position = glo_pos
		attack_box_shape.disabled = true
		attack_box_polygon.disabled = false
		attack_box.monitoring = true
		player.velocity = Vector2.ZERO
		player.doing_skill_3 = true
		can_skill = false
		skill_3_cd_gui.texture_over = cd_gui_0
		skill_3_cd_gui.max_value = 5
		skilling_timer.start(0.8)

func _on_skilling_timer_timeout():
	if is_lightning:
		player.doing_skill_3 = false
		attack_box_shape.disabled = true
		attack_box.monitoring = false
		is_lightning = false
	if is_water:
		if water_multipler ==2:
			water_multipler = 0
			last_torus_size = Vector2(25,50)
			attack_box_polygon.disabled = true
			attack_box_polygon.polygon = []
			is_water = false
			attack_box.monitoring = false
			skilling_timer.stop()
			attack_box.position = Vector2.ZERO
			skill_cd.start(5)

		else:
			attack_box_polygon.polygon = torus_points(last_torus_size.x+25, last_torus_size.y+50)
			player.doing_skill_3 = false
			last_torus_size += Vector2(25,50)
			skilling_timer.start(1)
			water_multipler += 1
	if is_wind:
		if winding:
			attack_box.monitoring = false
			attack_box_polygon.disabled = true
			attack_box_polygon.polygon = []
			is_wind = false
			skilling_timer.stop()
			attack_box.position = Vector2.ZERO
			winding = false
			skill_cd.start(5)
		else:
			skilling_timer.start(3)
			winding = true



func _on_skill_timer_timeout():
	can_skill = true
	skill_3_cd_gui.texture_over = cd_gui_1


func _on_attack_box_area_entered(area:Area2D):
	
	if area.get_parent() is Enemy:
		# print(area.get_parent().name," ", area.get_parent().enemy_stats.hp)
		# var bonus_atk = skill_tree.get_properties(skill_state)["bonus_atk"]
		# print(area.get_parent().name," ", area.get_parent().is_queued_for_deletion())
		if !area.get_parent().is_queued_for_deletion():
			area.get_parent().damaged(player.stats.att)
			area.get_parent().knockback(get_parent().position, 400)

func _on_attack_box_body_entered(body:Node2D):
	if body is Projectile:
		if body.what_skill == SkillTree.Skill_Tree.ENEMY:
			body.queue_free()
			
func torus_points(in_rad:int, out_rad:int, many_points:int = 36):
	var points = []

	for point in range(many_points+1):
		var angle = point * 2 * PI / many_points;
		var x = in_rad * cos(angle)
		var y = in_rad * sin(angle) -11.5
		points.append(Vector2(x,y))
	
	for point in range(many_points, -1,-1):
		var angle = point * 2 * PI / many_points;
		var x = out_rad * cos(angle)
		var y = out_rad * sin(angle) -11.5
		points.append(Vector2(x,y))

	return points

func set_equip(is_equipped:bool):
	if is_equipped:
		skill_3_cd_gui.texture_over = cd_gui_1
	else:
		skill_3_cd_gui.texture_over = cd_gui_0