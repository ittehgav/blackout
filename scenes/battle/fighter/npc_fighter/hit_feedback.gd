extends AudioStreamPlayer2D

@export var fighter:NpcFighter

@export var direct_hit:AudioStream;
@export var shielded_hit:AudioStream;
@export var prop_hit:AudioStream;

func _on_npc_fighter_damage_taken(damage: float, source: ActiveFighter, quiet: bool) -> void:
	if quiet or not (source is PlayerFighter):return
	if source is PlayerFighter:
		if damage > fighter.max_hp/3:
			pitch_scale = .75
		elif damage < fighter.max_hp/20:
			pitch_scale = 1.25;
		else:
			pitch_scale = randf_range(.9, 1.2);
	stream = direct_hit;
	play();

func _on_npc_fighter_damage_blocked(source: ActiveFighter, _value: float, quiet: bool) -> void:
	if quiet or not (source is PlayerFighter):return
	stream = shielded_hit;
	play()


func _on_prop_damage_taken(_damage: float, _source: ActiveFighter, quiet: bool) -> void:
	if not quiet:
		stream = prop_hit;
		play()
