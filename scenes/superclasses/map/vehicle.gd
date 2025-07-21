extends Sprite2D

class_name Vehicle

var party:MapParty;
@export var bounce_timer:Timer;
@export var auto_rotate_timer:Timer;




func adjust_direction(target_position:Vector2 = party.target_position)->void:
	if party.target_entity:
		auto_rotate_timer.start();
	var angle:float = rad_to_deg(global_position.angle_to_point(target_position)) + 90;
	if angle < 0:
		angle += 360
	if angle < 30 or angle > 330:## north
		frame = 0;
	elif angle < 60:## north west
		frame = 1;
		flip_h = false;
	elif angle < 120:## west
		frame = 2;
		flip_h = false;
	elif angle < 150:## south west
		frame = 3;
		flip_h = false;
	elif angle < 210:## south
		frame = 4;
	elif angle < 240:## south east
		frame = 3;
		flip_h = true;
	elif angle < 300:## east
		frame = 2;
		flip_h = true;
	else:## north west
		frame = 1;
		flip_h = true;






func _on_timer_timeout() -> void:
	if frame_coords.y == 2:
		bounce_timer.wait_time = .15
		frame_coords.y = 0;
	else:
		frame_coords.y +=1;
		if frame_coords.y == 2:
			bounce_timer.wait_time = .25
