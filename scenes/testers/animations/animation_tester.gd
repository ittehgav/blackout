extends Timer

var target:Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_parent();
	ColorCoder.color_code_fighter(target, randi_range(0, len(Index.color_schemes) - 1))


func next_frame() -> void:
	target.frame_coords.y = 1;
	if target.frame_coords.y == 1:
		if target.frame_coords.x == target.hframes - 1:
			target.frame_coords.x = 0;
		else:
			target.frame_coords.x += 1;
	elif target.frame_coords.y == 0:
		wait_time = .5
		if target.frame == 1:
			target.frame = 0;
		else:
			target.frame = 1;
