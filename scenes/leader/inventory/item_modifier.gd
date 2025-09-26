extends Node

class_name ItemModifier;

@export_enum("battle_start") var application:String="battle_start";

@export var stat_modifiers:CombatStats;
## only addition modifiers for now but eventually 
## create similar implementation to units' stats?

@export var prefix:String;
@export var suffix:String;
