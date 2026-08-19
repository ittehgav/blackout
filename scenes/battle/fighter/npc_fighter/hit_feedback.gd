extends AudioStreamPlayer2D

@export var fighter:NpcFighter

@export var direct_hit:AudioStream;
@export var shielded_hit:AudioStream;

func _on_npc_fighter_damage_taken(damage: float, source: ActiveFighter, quiet: bool) -> void:
	if quiet or not (source is PlayerFighter):return
	if source is PlayerFighter:
		volume_db = 0;
		if damage > fighter.max_hp/3:
			pitch_scale = .75
		elif damage < fighter.max_hp/20:
			pitch_scale = 1.25;
			volume_db = -10
		else:
			pitch_scale = randf_range(.9, 1.2);	1
	stream = direct_hit;
	play();

func _on_npc_fighter_damage_blocked(source: ActiveFighter, _value: float, quiet: bool) -> void:
	if quiet or not (source is PlayerFighter):return
	stream = shielded_hit;
	play()
