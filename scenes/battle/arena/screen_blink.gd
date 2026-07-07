extends ColorRect

var pending_blink:bool=false
const blink_time = .25
var blink_color:Color;
func screen_blink()->void:
	if pending_blink:
		color = blink_color;
		color.a = .75
		modulate.a = 0;

		var tween := create_tween()
		tween.tween_property(self, "modulate:a", .25, blink_time/2);
		tween.tween_property(self, "modulate:a", 0, blink_time/2);
		pending_blink = false
	


func _on_player_fighter_damage_taken(_damage: float, _source: ActiveFighter, quiet:bool) -> void:
	if not quiet:
		apply_screen_blink(FighterBase.combat_effect_colors.damage)


func _on_player_fighter_status_applied(_source: ActiveFighter, status: Status, quiet: bool) -> void:
		if not quiet:
			match status.type:
				"stun":
					apply_screen_blink(status.get_status_color())
				"stat_change":
					assert(status.value) 
					apply_screen_blink(status.get_status_color())
				
func apply_screen_blink(target:Color)->void:
	pending_blink = true
	if not pending_blink:
		blink_color = target;
	else:
		blink_color = blink_color/2 + target/2
	screen_blink.call_deferred()


func _on_player_fighter_knocked_back(_source: ActiveFighter, _strength: int) -> void:
	apply_screen_blink(FighterBase.combat_effect_colors.knockback)
