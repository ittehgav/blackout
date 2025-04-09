extends Sprite2D


@export var pointer:Sprite2D;

func _on_next_frame_timeout() -> void:
	if frame == 2:
		pointer.offset.y = 0;
		frame = 0;
	else:
		pointer.offset.y += 2.5;
		frame += 1;
	
func show_in_position(target:Vector2)->void:
	position = target + Vector2(5, 5);
	show();


func _on_in_map_player_started_moving() -> void:
	show_in_position(Entities.in_map_player.target_position)


func _on_in_map_player_stopped_moving() -> void:
	hide()
