extends SfxPlayer

@export var movement_started:AudioStream;
@export var settlement_visited:AudioStream;


func _on_player_party_settlement_visited(settlement: Settlement) -> void:
	play_sound_obj(settlement_visited)


func _on_player_party_started_moving() -> void:
	play_sound_obj(movement_started)
