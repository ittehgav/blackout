extends CombatVFX

class_name LightningVFX

const under_x_length = 128;


func shoot_bolt(source:Node2D, target:Node2D=null)->void:
	global_position = source.global_position
	if target:
		rotation = source.global_position.angle_to_point(target.global_position);	
		var distance:float = source.global_position.distance_to(target.global_position)
		var target_scale:float = (distance/under_x_length) * 2
		scale = Vector2(target_scale, 8)
	## just adjust angle in the pre animation
	## migrate every VFX to this because making this isometric work
	## properly is too much math for too little gain?
	frame_coords.x = 6;

	
	animation_player.play("lightning")
