extends Node2D

class_name CutsceneTrigger

func _on_body_entered(body:Node2D):
	if body is Player:
		if not name in CutsceneManager.cutscenes_completed:
			
			CutsceneManager.do_cutscene(name, self) 
