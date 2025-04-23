extends UIRoot


func start()->void:
	get_tree().paused = true;
	modulate.a = 0;
	show();
	var tween: = create_tween();
	tween.tween_property(self, "modulate:a", 1, .5);

func resume() -> void:
	get_tree().paused = false;
	hide();
