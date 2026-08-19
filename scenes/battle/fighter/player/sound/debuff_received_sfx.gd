extends SfxPlayer

@export var stat_debuff:AudioStream;
@export var stun:AudioStream;
@export var poison:AudioStream

func _on_player_fighter_status_applied(_source: ActiveFighter, status: Status, quiet: bool) -> void:
	if quiet:return;
	pitch_scale = 1
	match status.type:
		"dot":
			play_sound_obj(poison);
		"stun":
			play_sound_obj(stun);
		"stat_change":
			if status.value < 0:
				pitch_scale = 1.75;
				play_sound_obj(stat_debuff)
	
