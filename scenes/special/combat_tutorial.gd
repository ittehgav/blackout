extends Node2D



func _on_arena_ready() -> void:
	for f:ActiveFighter in Entities.arena.team_1.fighters:
		if f != Entities.player_fighter:
			f.set_process_mode(Node.PROCESS_MODE_DISABLED);
			
	for f:ActiveFighter in Entities.arena.team_2.fighters:
		f.set_process_mode(Node.PROCESS_MODE_DISABLED);
