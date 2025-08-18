extends Node

@export var unit:PlayerFighter;
@export var floating_icon_anchor:Node2D;

func _on_in_fight_player_status_applied(_source: ActiveFighter, data: Dictionary) -> void:
	match data.type:
		"stat_change":
			if data.stat != "move_speed":
				var icon:StatIcon = Index.scenes.ui.stat_icon.instantiate();
				icon.stat = data.stat;
				icon.floating = true;
				floating_icon_anchor.add_child(icon);
				## overrinding the default floating icon stuffs so player's VFX feel more important
				
				icon.global_position = floating_icon_anchor.global_position
				icon.panel.hide()
				if data.amount > 0:
					var tween: = create_tween();
					tween.tween_property(icon, "position:y", icon.position.y -30, 1);
					tween.tween_callback(icon.free)
				else:
					var tween: = create_tween();
					tween.tween_property(icon, "position:y", icon.position.y +30, 1);
					tween.tween_callback(icon.free)


func _on_in_fight_player_status_removed(status_type: String, _data: Dictionary) -> void:
	match status_type:
		"stun":
			unit.base.modulate = Color.WHITE;
