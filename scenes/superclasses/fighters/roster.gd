extends Node

class_name Roster;

@export var units:Array[FighterUnit];

## where functions related to party will be implemented such as
## checking upkeep costs
## calculating speed/theat level type stuff


func _on_child_entered_tree(unit: Node) -> void:
	assert(unit is FighterUnit)
	units.push_back(unit)


func _on_child_exiting_tree(unit: Node) -> void:
	units.erase(unit)
