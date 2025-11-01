extends Node


## TODO find a better place for this and remove this script?
var player_pre_suppress_move_speed:int;
func suppress_fighter(target:ActiveFighter)->void:
	## will bother implementing this for NPC fighters 
	## once there's anything that suppresses them 
	if target is PlayerFighter:
		player_pre_suppress_move_speed = target.move_speed;
		target.move_speed = 0
		target.equipment.process_mode = Node.PROCESS_MODE_DISABLED;
		
func clear_suppress(target:ActiveFighter)->void:
	if target is PlayerFighter:
		target.move_speed = player_pre_suppress_move_speed;
		target.equipment.process_mode = Node.PROCESS_MODE_INHERIT;
