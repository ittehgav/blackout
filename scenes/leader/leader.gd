extends Node

class_name Leader

@export var color_scheme_index:int;

@export var level:int = 1;
@export var experience:int = 0;

@export var inventory:Inventory;
@export var roster:Roster;

@export var stats:CombatStats;
@export var modifier_stats:CombatStats;
@export var stat_multipliers:CombatStats;


@export var sight_range:int;

@onready var party_name:String = name;


func final_stats()->CombatStats:
	var modified_stats:CombatStats = CombatStats.new();

	for stat:String in CombatStats.all_stats:
		modified_stats[stat] = final_stat(stat)
	return modified_stats;

func final_stat(stat:String)->float:
	return (stats[stat] + modifier_stats[stat]) * stat_multipliers[stat]


func get_party_level()->int:
	return level * 2 + roster.get_level();
