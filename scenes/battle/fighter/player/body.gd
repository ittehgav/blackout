extends FighterBase

class_name PlayerFighterBase;



var current_state:String = "idle";




func _process(_delta:float)->void:
	var mouse_x:int = get_global_mouse_position().x;
	var global_x:int = global_position.x
	flip_h = mouse_x < global_x;
	if flip_h:
		if fighter.velocity.x < 0:
			animation_player.speed_scale = 1;
		else:
			animation_player.speed_scale = -1
	else:
		if fighter.velocity.x > 0:
			animation_player.speed_scale = 1;
		else:
			animation_player.speed_scale = -1
