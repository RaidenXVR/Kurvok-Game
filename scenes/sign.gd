extends StaticBody2D

class_name Sign

@export var sign_text: String

func see_sign():
	var dialogue_node: Dialogue = get_tree().root.get_node("World").get_node("CanvasLayer").find_child("Dialogue")
	sign_text = sign_text.replace("|", "\n")
	var sign_dict = [{"char": "", "dialogue": sign_text}]
	dialogue_node.starter(sign_dict, "", null, true, [])
	

