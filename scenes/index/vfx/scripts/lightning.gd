extends CombatVFX

const over_x_length = 64;
const under_x_length = 128;

const true_diagonal_angles = [
	## for adjusting the angles properly
	1.0472,
	2.0944
]

const angle_offsets = [
	-PI/2, ## 0 = bottom
	-true_diagonal_angles[0], ## 1 = bottom-left
	0, ## 2 = left, origin
	true_diagonal_angles[0], ## 3 = top-left
	PI/2, ## 4 = top
	true_diagonal_angles[1], ## 5 = top-right
	PI, ## 6 = right (-PI if beneath x axis
	-true_diagonal_angles[1] ## 7 = bottom-right
	
]

func bolt_animation(source:ActiveFighter, target:ActiveFighter)->void:
	## will be used in pretty much every lightning mechanic
	global_position = source.global_position;
	await get_tree().process_frame
	var angle:float = global_position.angle_to_point(target.global_position);
	var angle_index:int = get_sector(angle)
	
	frame_coords.x = angle_index;
	
	var distance:float = source.position.distance_to(target.position)
	var stretch_base:int;
	if angle_index <= 2 or angle_index >= 6:
		stretch_base = under_x_length;
	else:
		stretch_base = over_x_length;
	
	var target_scale:float = distance/stretch_base;
	scale = Vector2(target_scale, target_scale)
	
	#var angle_offset:float = angle_offsets[angle_index];
	#rotation = -angle + angle_offset TODO nudge the rotation a little toward the target

	animation_player.play("lightning")

func get_sector(angle: float) -> int:
	return int(fposmod(angle - PI / 2, TAU) / (PI / 4)) % 8
