extends  Resource

class_name Data

@export var chest_states:Dictionary = {}
@export var player_stats: Stats = Stats.new()
@export var player_inventory: Inventory = Inventory.new()
#@export var items_equiped:Array[int] = [] #0 helmet, 1 torso, 2 boots, 3 weap1, 4 weap2, 5 acc1, 6 acc2
@export var armor_equip1:InventoryItems
@export var armor_equip2: InventoryItems
@export var armor_equip3: InventoryItems
@export var weapon_equip: InventoryItems
@export var main_quest_state: String = "MQ Name"

@export var enemy_slain: Dictionary= {}
@export var money : int = 10

@export var current_skill_tree = SkillTree.Skill_Tree.LIGHTNING
@export var current_skill_equipped = 1
@export var skill_learned: Array[Skill] = [load("res://player/Skills/skills/lightning_thrust.tres"), load("res://player/Skills/skills/thunder_eagle.tres"),load("res://player/Skills/skills/lightning_burst.tres"), load("res://player/Skills/skills/default_combo.tres")]
@export var skill_available: Array[Skill] = []
@export var skill_slot_1:Skill = skill_learned[0]
@export var skill_slot_2:Skill = skill_learned[1]
@export var skill_slot_3:Skill = skill_learned[2]
@export var skill_passive:Skill = skill_learned[3]

@export var available_quests:Array[Quest] = []
@export var ongoing_quests:Array[Quest] = []
@export var completed_quests:Array[Quest] = []
@export var current_main_quest: MainQuest
@export var completed_main_quest: Array[MainQuest]

@export var cutscenes_completed:Array[String]

@export var map_name:String = "NorthGate"
@export var player_position: Vector2 = Vector2(1000,50)

func save_data(player_pos:Vector2, map_nm:String):
	chest_states = GameData.chest_states
	player_stats = GameData.player_stats
	player_inventory = GameData.player_inventory
	#items_equiped = GameData.items_equiped
	armor_equip1 = GameData.armor_equip1
	armor_equip2 = GameData.armor_equip2
	armor_equip3 = GameData.armor_equip3
	weapon_equip = GameData.weapon_equip
	
	main_quest_state = GameData.main_quest_state
	enemy_slain = GameData.enemy_slain
	money = GameData.money
	
	current_skill_tree = GameData.current_skill_tree
	current_skill_equipped = GameData.current_skill_equipped
	skill_learned =  GameData.skill_learned
	skill_available = GameData.skill_available
	skill_slot_1 = GameData.skill_slot_1
	skill_slot_2 = GameData.skill_slot_2
	skill_slot_3 = GameData.skill_slot_3
	skill_passive = GameData.skill_passive
	
	available_quests = QuestManager.available_quests
	ongoing_quests = QuestManager.ongoing_quests
	completed_quests = QuestManager.completed_quests
	current_main_quest = QuestManager.current_main_quest
	completed_main_quest = QuestManager.completed_main_quest
	
	cutscenes_completed = CutsceneManager.cutscenes_completed

	map_name = map_nm
	player_position = player_pos

