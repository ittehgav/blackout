extends Node

@export var unit:InFightPlayer;


func _on_in_fight_player_status_applied(source: ActiveFighter, data: Dictionary) -> void:
	match data.type:
			"stun":
				unit.body.switch_animation("idle")


func _on_in_fight_player_status_removed(status_type: String, data: Dictionary) -> void:
	match status_type:
		"stun":
			unit.base.modulate = Color.WHITE;
