extends Sprite2D


@export var linger:Timer;
func _process(_delta:float)->void:
	if Input.is_action_pressed("shift_press"):
		frame_coords.y = 1;
	elif Input.is_action_just_released("shift_press"):
		frame_coords.y = 2;
		linger.start()
	else:
		frame_coords.y = 0;
