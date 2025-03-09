extends Node2D

class_name Team;

@export var team_n:int;

var units:Array[Node];

var fleeing:bool;


func refresh_units():
	## buffers the children so get_children doesn't get called several times in a single process frame at times
	units = get_children();

func on_unit_death(_killer, unit:ActiveFighter)->void:
	if unit.is_inside_tree():
		await unit.tree_exited;
		refresh_units();
	else:
		refresh_units()
	
