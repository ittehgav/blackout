extends Control

@export var morale_icon:MoraleIcon;


func start_sequence()->void:
	show()
	var player:Player = get_tree().get_first_node_in_group("player");
	player.morale -= player.morale/3;
	morale_icon.animated_update();
