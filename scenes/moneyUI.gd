extends Control

@onready var money_text = $MoneyText

# Called when the node enters the scene tree for the first time.
func _ready():
	money_text.text = str(GameData.money)

func money_changed(money):
	money_text.text = str(money)