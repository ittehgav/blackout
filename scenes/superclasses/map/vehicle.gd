extends Sprite2D

class_name Vehicle
## keeping vehicles as unique objects instead of just one sprite2D node with interchangeable
## because eventually vehicles will be more unique

@export var bounce_timer:Timer;
var current_direction:Vector2i

func bounce_animation() -> void:
	if frame_coords.y == 2:
		bounce_timer.wait_time = .15
		frame_coords.y = 0;
	else:
		frame_coords.y +=1;
		if frame_coords.y == 2:
			bounce_timer.wait_time = .25

func adjust_direction(direction:Vector2i)->void:
	current_direction = direction
	match direction:
		Vector2i.UP:
			frame_coords.x = 0;
		Vector2i.RIGHT:
			frame_coords.x = 2;
			flip_h = false;
		Vector2i.DOWN:
			frame_coords.x = 4;
		Vector2i.LEFT:
			frame_coords.x = 2;
			flip_h = true;
