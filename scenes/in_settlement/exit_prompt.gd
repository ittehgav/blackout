extends Control

func exit_prompt()->void:
	get_tree().paused = true;
	Tweens.ui_fade_in(self);
	


func _on_leave_pressed() -> void:
	Entities.current_area.return_to_world_map();


func _on_stay_pressed() -> void:
	Tweens.ui_fade_out(self);
	get_tree().paused = false;
