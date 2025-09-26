extends Node2D

signal battle_started

func _ready()->void:
	## PASS THIS STsdUFF TO REGULAR ARENA EVENTUALLY
	var projections:Array[Node] = get_tree().get_nodes_in_group("aoe_projections");
	var player_team_n:int = Entities.player_fighter.ally_team.team_n;
	for p in projections:
		if p.owner.fighter.ally_team.team_n == player_team_n:
			p.hide();
