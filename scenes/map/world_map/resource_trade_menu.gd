extends Control

func open()->void:
	var player = Entities.in_map_player.leader;
	var settlement = Entities.current_settlement;


	show()
