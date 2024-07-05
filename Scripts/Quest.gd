extends Resource

class_name Quest

enum Quest_State{UNSTARTED, IN_PROGRESS, COMPLETED}
enum Quest_Types{KILL, GATHER, TALK}


@export var quest_name:String
@export var quest_description:String
@export var quest_requirement:Array[String]
@export var type:Quest_Types
@export var giver:String
@export var target:Dictionary
@export var current_target_amount:Dictionary
@export var rewards:Dictionary
@export var state: Quest_State = Quest_State.UNSTARTED
@export var is_main_quest:bool = false

