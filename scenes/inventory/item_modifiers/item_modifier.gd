extends Node

class_name ItemModifier;

@export_enum("battle_start") var application:String="battle_start";

@export_range(1, 3) var tier:int = 1;

@export var stat_modifiers:CombatStats;
@export var stat_multiplier:CombatStats;
## only addition modifiers for now but eventually 
## create similar implementation to units' stats?

@export var prefix:String;
@export var suffix:String;

@export var description:String;

func apply_to_item(target:Item)->void:
	var mod:ItemModifier = duplicate(DUPLICATE_USE_INSTANTIATION);
	## doesnt need to enter tree as long as it's refered to by item
	target.applied_modifier = mod
	mod.name = name;

func get_description()->String:
	if description:
		return description;
	else:
		var stat_bonuses:String="";
		if stat_modifiers:
			for stat:String in CombatStats.all_stats:
				if stat_modifiers[stat]:
					stat_bonuses += Index.get_color_tag(stat) + "+"+str(stat_modifiers[stat]) + " " + stat+"\n"
		assert(len(stat_bonuses));
		return stat_bonuses.strip_edges()
