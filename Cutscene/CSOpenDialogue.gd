extends Resource

class_name Cutscene_Dialogue

@export var cutscene_name: String
@export var dialogue_phase: String


var lines: Array
var actors: Array


func init_vars():
    var file_diag = FileAccess.get_file_as_string("res://Cutscene/cutscene_dialogue.json")
    var parsed = JSON.parse_string(file_diag)
    var dialogs = parsed[cutscene_name]
    lines = dialogs[dialogue_phase]["dialogue"] as Array[Dictionary]
    actors = dialogs[dialogue_phase]["actors"] as Array[String]