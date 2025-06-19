extends Control


func _input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_pause"):
		## no pause stack = player in world map view:
		if not visible and not Entities.world_map.pause_stack:
			Tweens.ui_fade_in(self);
			Entities.world_map.pause_map();
		elif Entities.world_map.pause_stack and visible:
			Tweens.ui_fade_out(self);
			Entities.world_map.unpause_map()
		
		


func _on_resume_pressed() -> void:
	Tweens.ui_fade_out(self)
	Entities.world_map.unpause_map()

func _on_save_pressed() -> void:
	SaveSystem.save_data()
