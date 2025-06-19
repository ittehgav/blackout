extends Node

class_name Roster;

@export var units:Array[FighterUnit];

## where functions related to party will be implemented such as
## checking upkeep costs
## calculating speed/theat level type stuff
func add_unit(unit:FighterUnit)->void:
	if unit.is_inside_tree():
		reparent(unit)
	else:
		add_child(unit);
	if not is_inside_tree():
		## right now only for testing but may run into a similar problem to the 
		units.push_back(unit);
		## just so it set itself up before battle
		unit.update_stats()
		
		

func _on_child_entered_tree(unit: Node) -> void:
	## INVENTORIES AND ROSTERS JUST NEED TO HAVE THE UNITS AS CHILDREN TO PROPERLY CATEGORIZE THEM
	assert(unit is FighterUnit)
	if not unit in units:
		add_unit(unit)


func _on_child_exiting_tree(unit: Node) -> void:
	units.erase(unit)
