extends Sprite2D

@export var projection:Sprite2D;

@export var camera:Camera2D;
@export var sfx:AudioStreamPlayer;


func _process(_delta:float)->void:
	if Input.is_action_just_pressed("place_marker") and not Entities.world_map.pause_stack:
		if not visible:
			show_in_position(Entities.world_map.get_local_mouse_position());
		else:
			sfx.play_sound_by_key("marker_removed")
			projection.hide();
			hide();

	if visible:
		var window_size:Vector2 = get_window().size;
		
		var x_gap_limit:float = window_size.x/2;
		var y_gap_limit:float = window_size.y/2;
		
		
		var x_gap:float = global_position.x - camera.global_position.x
		var y_gap:float = global_position.y - camera.global_position.y
		var off_x_range:bool = abs(x_gap) > x_gap_limit + 20;
		var off_y_range:bool = abs(y_gap) > y_gap_limit + 30;
		
		projection.hide();
		projection.global_position = global_position
		
		if off_x_range:
			projection.show()

			projection.position.x = x_gap_limit - 30;
			if x_gap < 1:
				projection.position.x *= -1
				
		if off_y_range:
			projection.show();
			projection.position.y = y_gap_limit - 20;
			if y_gap < 0:
				projection.position.y *= -1;
		
		
func show_in_position(target:Vector2)->void:
	sfx.play_sound_by_key("marker_placed")
	position = target + Vector2(5, 5);
	show();
