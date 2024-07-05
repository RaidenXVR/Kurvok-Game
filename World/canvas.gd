extends CanvasLayer

@onready var inv = $Inventory
@onready var dia_box = $Dialogue
@onready var shop_gui = $ShopGUI
@onready var player_healthbar = $PlayerHealthBar
@onready var manabar = $ManaBar
@onready var skill_1_gui = $Skill1CD
@onready var skill_2_gui = $Skill2CD
@onready var skill_3_gui = $Skill3CD
@onready var gold = $MoneyUI
@onready var mana = $ManaBar

var minim_alpha = 100
var is_shopping = false


# Called when the node enters the scene tree for the first time.
func _ready():
	inv.close()
	dia_box.visible = false
	shop_gui.visible = false


func _input(event):
	if event.is_action_pressed("inventory") and not is_shopping:
		if inv.is_open:
			inv.close()
			player_healthbar.visible = true
			manabar.visible = true
			skill_1_gui.visible = true
			skill_2_gui.visible = true
			skill_3_gui.visible = true
			gold.visible = true
		else:
			gold.visible = false
			player_healthbar.visible = false
			manabar.visible = false
			skill_1_gui.visible = false
			skill_2_gui.visible = false
			skill_3_gui.visible = false
			inv.open()

func set_alpha(is_on_top:bool):
	if is_on_top:
		player_healthbar.modulate = "ffffff64"
		manabar.modulate = "ffffff64"
		skill_1_gui.modulate ="ffffff64"
		skill_2_gui.modulate = "ffffff64"
		skill_3_gui.modulate = "ffffff64"
		gold.modulate = "ffffff64"
	
	else:
		player_healthbar.modulate = "ffffff"
		manabar.modulate = "ffffff"
		skill_1_gui.modulate ="ffffff"
		skill_2_gui.modulate = "ffffff"
		skill_3_gui.modulate = "ffffff"
		gold.modulate = "ffffff"