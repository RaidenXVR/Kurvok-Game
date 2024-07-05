extends  Resource

class_name Data

@export var chest_states = {}
@export var player_stats: Stats
@export var player_inventory: Inventory
# @export var items_id_consum:Array[Dictionary] = []
# @export var items_id_equip:Array[Dictionary] = []
# @export var items_id_key:Array[Dictionary] = []
@export var items_equiped:Array[int] = [] #0 helmet, 1 torso, 2 boots, 3 weap1, 4 weap2, 5 acc1, 6 acc2
@export var main_quest_state: String = "MQ Name"

@export var enemy_slain: Dictionary= {}
@export var money : int = 10
@export var current_skill_tree = SkillTree.Skill_Tree.WIND
@export var current_skill_equipped = 1

@export var available_quests:Array[Quest]
@export var ongoing_quests:Array[Quest]
@export var completed_quests:Array[Quest]

@export var map_name:String
@export var player_position: Vector2

func save_data(player_pos:Vector2, map_nm:String):
    chest_states = GameData.chest_states
    player_stats = GameData.player_stats
    player_inventory = GameData.player_inventory
    # items_id_consum = GameData.items_id_consum
    # items_id_equip = GameData.items_id_equip
    # items_id_key = GameData.items_id_key
    items_equiped = GameData.items_equiped
    main_quest_state = GameData.main_quest_state
    enemy_slain = GameData.enemy_slain
    money = GameData.money
    current_skill_tree = GameData.current_skill_tree
    current_skill_equipped = GameData.current_skill_equipped

    available_quests = QuestManager.available_quests
    ongoing_quests = QuestManager.ongoing_quests
    completed_quests = QuestManager.completed_quests
    
    map_name = map_nm
    player_position = player_pos


