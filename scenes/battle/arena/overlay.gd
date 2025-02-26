extends Control

@export var in_fight_player:InFightPlayer;

#func _ready() -> void:
	#print(global_position, " OG")
	#print(in_fight_player.global_position, " PG\n\n")
	#var shift = global_position - in_fight_player.global_position
	#position += (shift * -1);
	#print(position)
