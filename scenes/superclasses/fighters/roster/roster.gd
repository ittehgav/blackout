extends Node

class_name Roster;

@export var units:Array[FighterUnit];

## where functions related to party will be implemented such as
## checking upkeep costs
## calculating speed/theat level type stuff
func add_unit(unit:FighterUnit)->void:
	assert(not units.has(unit));
	units.append(unit)


func _on_child_entered_tree(node: Node) -> void:
	## so editor-made roster work and are easy to edit
	assert(node is FighterUnit)
	if not units.has(node):
		add_unit(node)
	remove_child.call_deferred(node);
