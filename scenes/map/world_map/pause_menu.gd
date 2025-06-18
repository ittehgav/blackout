extends Control


func _input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_pause"):
		if not visible:
			Tweens.ui_fade_in(self);
			Entities.world_map.pause_map();
		else:
			Tweens.ui_fade_out(self);
			
		
		


func _on_resume_pressed() -> void:
	Tweens.ui_fade_out(self)


func _on_save_pressed() -> void:
	SaveSystem.save_data()
