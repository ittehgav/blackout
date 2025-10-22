extends Node

class_name Roster;

@export var units:Array[FighterUnit];

var equipped_accessories:Array[Accessory]


func add_unit(unit:FighterUnit)->void:
	assert(not units.has(unit));
	units.append(unit)
func remove_unit(unit:FighterUnit)->void:
	assert(units.has(unit));
	units.erase(unit)


func _on_child_entered_tree(node: Node) -> void:
	## so editor-made roster work and are easy to edit
	assert(node is FighterUnit)
	if not units.has(node):
		add_unit(node)
	remove_child.call_deferred(node);
	
func get_level()->int:
	var level:int = 0;
	## TODO make this more sophisticated?
	## more value from:
	## having more unique units
	for unit:FighterUnit in units:
		## higher unit count yields more than just higher average levels
		level += (1 + unit.level)* len(unit.base.tags);
	return level

func clear_units()->void:
	## units just get freed as they become unreferenced?
	while len(units):
		remove_unit(units[0]);

func get_exp_bounty()->int:
	## probably some tweaking to be done?
	var base_bounty:int = get_level();
	return base_bounty
