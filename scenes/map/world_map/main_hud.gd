extends Control

@export var panel:Panel;


func _on_panel_mouse_entered() -> void:
	fade_panel_in();


func _on_panel_mouse_exited() -> void:
	fade_panel_out();
	
func fade_panel_in():
	var tween = create_tween();
	tween.tween_property(panel, "self_modulate:a", 1, .5);

func fade_panel_out():
	var tween = create_tween();
	tween.tween_property(panel, "self_modulate:a", .9, .5);
