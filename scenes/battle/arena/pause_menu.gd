extends UIRoot


func start()->void:
	get_tree().paused = true;
	Tweens.ui_fade_in(self);

func resume() -> void:
	get_tree().paused = false;
	hide();
