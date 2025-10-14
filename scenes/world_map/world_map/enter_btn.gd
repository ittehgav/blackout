extends Button


var current_settlement:Settlement;
@export var dungeon_prompt:Control;

func _on_player_party_settlement_visited(settlement: Settlement) -> void:
	global_position = settlement.global_position + Vector2(-size.x/2, 50);
	current_settlement = settlement
	Tweens.ui_fade_in(self)


func _on_pressed() -> void:
	var location:Location = current_settlement.locations[0]
	if location is Building:
		Entities.world_map.enter_settlement()
	elif location is Dungeon:
		dungeon_prompt.load_dungeon(location);
	hide()


func _on_player_party_started_moving() -> void:
	hide()
