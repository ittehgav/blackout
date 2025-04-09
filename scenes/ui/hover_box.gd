extends ColorRect

@export var hover_target:Control;

func _ready()->void:
	hover_target.mouse_entered.connect(show);
	hover_target.mouse_exited.connect(hide);
