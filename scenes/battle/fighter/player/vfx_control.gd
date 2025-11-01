extends Node

@export var unit:PlayerFighter;
@export var floating_icon_anchor:Control;

func _on_in_fight_player_status_applied(_source: ActiveFighter, status:Status) -> void:
	match status.type:
		"stat_change":
			if status.stat != "move_speed":
				var icon:StatIcon = Index.scenes.ui.stat_icon.instantiate();
				icon.stat = status.stat;
				icon.floating = true;
				icon.positive = status.value > 0
				floating_icon_anchor.add_child(icon);
				## overrinding the default floating icon stuffs so player's VFX feel more important



func _on_in_fight_player_status_removed(status:Status) -> void:
	match status.type:
		"stun":
			unit.base.modulate = Color.WHITE;
