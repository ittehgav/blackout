extends Control

@export var screen_blink_rect:ColorRect

const blink_time = .25
func screen_blink(target_color:Color)->void:
	screen_blink_rect.color = target_color;
	screen_blink_rect.modulate.a = 0;

	var tween := create_tween()
	tween.tween_property(screen_blink_rect, "modulate:a", .25, blink_time/2);
	tween.tween_property(screen_blink_rect, "modulate:a", 0, blink_time/2);


func _on_player_fighter_damage_taken(_damage: float, _source: ActiveFighter) -> void:
	screen_blink(Color.RED)
