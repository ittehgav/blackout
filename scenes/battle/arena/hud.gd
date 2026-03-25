extends UIRoot


@export var screen_blink_rect:ColorRect


const blink_time = .25
func screen_blink(target_color:Color)->void:
	screen_blink_rect.color = target_color;
	screen_blink_rect.modulate.a = 0;

	var tween := create_tween()
	tween.tween_property(screen_blink_rect, "modulate:a", .25, blink_time/2);
	tween.tween_property(screen_blink_rect, "modulate:a", 0, blink_time/2);


func _on_player_fighter_damage_taken(_damage: float, _source: ActiveFighter, quiet:bool) -> void:
	if not quiet:
		screen_blink(Color.RED)


func _on_player_fighter_status_applied(_source: ActiveFighter, status: Status, quiet: bool) -> void:
		if not quiet:
			match status.type:
				"dot":
					screen_blink(Color.DARK_OLIVE_GREEN)
				"stun":
					screen_blink(Color.PURPLE)
				"stat_change":
					if status.value < 0:
						screen_blink(Color.DIM_GRAY)
		
