extends Node

class_name Leader

@export var color_scheme_index:int;

## Npc leaders don't gain EXP, they spawn with a lavel based on the region they're at
@export var level:int = 1;

@export var inventory:Inventory;
@export var roster:Roster;

@export var stats:CombatStats;
@export var modifier_stats:CombatStats;
@export var stat_multipliers:CombatStats;


@export var sight_range:int;

@onready var party_name:String = name;


func final_stats()->CombatStats:
	var modified_stats:CombatStats = Index.scenes.combat_stats.instantiate();
	for stat:String in Index.all_combat_stats:
		modified_stats[stat] = (stats[stat] + modifier_stats[stat]) * stat_multipliers[stat]
	return modified_stats;


func get_party_level()->int:
	return level * 2 + roster.get_level();
