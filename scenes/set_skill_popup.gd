extends Control

var skill_list:Array[Skill] = GameData.skill_learned
var current_slot:int

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for skill in skill_list: 
		var butt = load("res://scenes/set_skill_button.tscn").instantiate() as TextureButton
		butt.texture_normal = skill.icon
		butt.set_meta("skill", skill)
		butt.disabled = true
		$SkillsContainer.add_child(butt)
		if skill == GameData.skill_slot_1 or skill == GameData.skill_slot_2 or skill == GameData.skill_slot_3:
			butt.get_child(0).text = "E"
			#butt.button_pressed = true
		butt.button_down.connect(func():_on_set_skill_button_down(butt.get_index()))
		butt.focus_entered.connect(func():_on_skill_button_focused(skill))
		butt.mouse_entered.connect(func():_on_skill_button_focused(skill))
	
	if GameData.skill_slot_1:
		$EquippedSkill1.texture_normal = GameData.skill_slot_1.icon
		get_parent().get_parent().get_node("HBoxContainer/Skill1").texture = GameData.skill_slot_1.icon
	if GameData.skill_slot_2:
		$EquippedSkill2.texture_normal = GameData.skill_slot_2.icon
		get_parent().get_parent().get_node("HBoxContainer/Skill2").texture = GameData.skill_slot_2.icon
	if GameData.skill_slot_3:
		$EquippedSkill3.texture_normal = GameData.skill_slot_3.icon
		get_parent().get_parent().get_node("HBoxContainer/Skill3").texture = GameData.skill_slot_3.icon
	if GameData.skill_passive:
		$PassiveSkill.texture_normal = GameData.skill_passive.icon

func _on_set_skill_button_down(index):
	match current_slot:
		0:
			if $SkillsContainer.get_child(index).get_meta("skill") == GameData.skill_slot_1:
				GameData.skill_slot_1 = null
				$SkillsContainer.get_child(index).get_child(0).text = ""
			else:
				if GameData.skill_slot_1 != null:
					var last_equipped_butt = $SkillsContainer.get_children().filter(func(s): return s.get_meta("skill") == GameData.skill_slot_1).front()
					last_equipped_butt.get_child(0).text = ""
					last_equipped_butt.disabled = false
				GameData.skill_slot_1 = $SkillsContainer.get_child(index).get_meta("skill")
				$SkillsContainer.get_child(index).get_child(0).text = "E"
			GameData.equip_skill_change.emit()
		1:
			if $SkillsContainer.get_child(index).get_meta("skill") == GameData.skill_slot_2:
				GameData.skill_slot_2 = null
				$SkillsContainer.get_child(index).get_child(0).text = ""
			else:
				if GameData.skill_slot_2 != null:
					var last_equipped_butt = $SkillsContainer.get_children().filter(func(s): return s.get_meta("skill") == GameData.skill_slot_2).front()
					last_equipped_butt.get_child(0).text = ""
					last_equipped_butt.disabled = false
				GameData.skill_slot_2 = $SkillsContainer.get_child(index).get_meta("skill")
				$SkillsContainer.get_child(index).get_child(0).text = "E"
			GameData.equip_skill_change.emit()
		2:
			if $SkillsContainer.get_child(index).get_meta("skill") == GameData.skill_slot_3:
				GameData.skill_slot_3 = null
				$SkillsContainer.get_child(index).get_child(0).text = ""
			else:
				if GameData.skill_slot_3 != null:
					var last_equipped_butt = $SkillsContainer.get_children().filter(func(s): return s.get_meta("skill") == GameData.skill_slot_3).front()
					last_equipped_butt.get_child(0).text = ""
					last_equipped_butt.disabled = false
				GameData.skill_slot_3 = $SkillsContainer.get_child(index).get_meta("skill")
				$SkillsContainer.get_child(index).get_child(0).text = "E"
			GameData.equip_skill_change.emit()
		3:
			if $SkillsContainer.get_child(index).get_meta("skill") == GameData.skill_passive:
				GameData.skill_passive = null
				$SkillsContainer.get_child(index).get_child(0).text = ""
			else:
				if GameData.skill_passive != null:
					var last_equipped_butt = $SkillsContainer.get_children().filter(func(s): return s.get_meta("skill") == GameData.skill_passive).front()
					last_equipped_butt.get_child(0).text = ""
					last_equipped_butt.disabled = false
				GameData.skill_passive = $SkillsContainer.get_child(index).get_meta("skill")
				$SkillsContainer.get_child(index).get_child(0).text = "E"


func _on_skill_button_focused(meta:Skill):
	$SkillIcon.texture = meta.icon
	$Desc.text = meta.skill_description



func _on_equipped_skill_1_button_down():

	for butt in $SkillsContainer.get_children():
		var meta:Skill = butt.get_meta("skill")
		if meta.skill_category == Skill.SkillCategory.SKILL_PASSIVE:
			butt.modulate = Color(0,0,0,0.2)
			butt.disabled = true
		elif  meta == GameData.skill_slot_2 or meta == GameData.skill_slot_3:
			butt.disabled = true
			butt.modulate = Color(0,0,0,0.2)
			butt.get_child(0).text = "E"
		else:
			butt.disabled = false
			butt.modulate = Color(1,1,1,1)
	$SkillsContainer.get_child(0).grab_focus()
	current_slot = 0



func _on_equipped_skill_2_button_down():
	for butt in $SkillsContainer.get_children():
		var meta:Skill = butt.get_meta("skill")
		if meta.skill_category == Skill.SkillCategory.SKILL_PASSIVE:
			butt.modulate = Color(0,0,0,0.2)
			butt.disabled = true
		elif  meta == GameData.skill_slot_1 or meta == GameData.skill_slot_3:
			butt.disabled = true
			butt.modulate = Color(0,0,0,0.2)
			butt.get_child(0).text = "E"
		else:
			butt.disabled = false
			butt.modulate = Color(1,1,1,1)
	$SkillsContainer.get_child(0).grab_focus()
	current_slot = 1


func _on_equipped_skill_3_button_down():
	for butt in $SkillsContainer.get_children():
		var meta:Skill = butt.get_meta("skill")
		if meta.skill_category == Skill.SkillCategory.SKILL_PASSIVE:
			butt.modulate = Color(0,0,0,0.2)
			butt.disabled = true
		elif  meta == GameData.skill_slot_1 or meta == GameData.skill_slot_2:
			butt.disabled = true
			butt.modulate = Color(0,0,0,0.2)
			butt.get_child(0).text = "E"
		else:
			butt.disabled = false
			butt.modulate = Color(1,1,1,1)
	$SkillsContainer.get_child(0).grab_focus()
	current_slot = 2


func _on_passive_skill_button_down():
	for butt in $SkillsContainer.get_children():
		var meta:Skill = butt.get_meta("skill")
		if meta.skill_category != Skill.SkillCategory.SKILL_PASSIVE:
			butt.modulate = Color(0,0,0,0.5)
			butt.disabled = true
		else:
			butt.disabled = false
			butt.modulate = Color(1,1,1,1)
	current_slot = 3
	$SkillsContainer.get_child(0).grab_focus()


func _on_hidden():
	print("hidden called")
	current_slot = 4
	visible = false
	for butt in $SkillsContainer.get_children():
		butt.disabled = true

