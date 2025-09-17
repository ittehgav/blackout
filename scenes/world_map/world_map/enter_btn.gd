extends Button


var current_settlement:Settlement;

func _on_player_party_settlement_visited(settlement: Settlement) -> void:
	global_position = settlement.global_position + Vector2(-size.x/2, 50);
	current_settlement = settlement
	Tweens.ui_fade_in(self)


func _on_pressed() -> void:
	Entities.world_map.enter_settlement()
	hide()


func _on_player_party_started_moving() -> void:
	hide()
