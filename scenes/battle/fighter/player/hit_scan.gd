extends Area2D

var follow_cursor:bool=false;

func _process(_delta: float) -> void:
	if follow_cursor:
		global_position = get_global_mouse_position();
