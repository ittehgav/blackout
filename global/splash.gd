extends CanvasLayer

@export var screen:Control;

func show_loading_screen()->Tween:
	var tween:Tween = Tweens.ui_fade_in(screen);
	return tween;


func set_fade_callback(target:Signal)->void:
	target.connect(Tweens.ui_fade_out.bind(screen), ConnectFlags.CONNECT_ONE_SHOT);
