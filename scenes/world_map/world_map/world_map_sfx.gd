extends SfxPlayer

@export var movement_started:AudioStream;
@export var location_visited:AudioStream;


func _on_player_party_location_visited(_location: Location) -> void:
	play_sound_obj(location_visited)


func _on_player_party_started_moving() -> void:
	play_sound_obj(movement_started)
