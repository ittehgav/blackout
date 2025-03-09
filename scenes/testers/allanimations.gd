extends Node2D

func _input(e:InputEvent)->void:
	if e is InputEventMouseButton and e.button_index == 1:
		var tween = create_tween();
		for c in get_children():
			tween.parallel().tween_property(self, "global_position", get_global_mouse_position(), 2);
