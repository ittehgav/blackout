@icon("res://assets/visual/editor_ui/IconGodotNode/node/icon_list.png")
extends Node

class_name CombatStats;
## data class for combat stats
## that will be added as nodes so its better to keep it as a node class
const all_stats  = [
	## having their keys as strings that you can use on the stats node itself
	## is much easier to use than if i made an enum-based structure
	"max_hp",
	"attack",
	"defense",
	"agility",
	"technique"
]

const stat_colors:Dictionary[String, Color] = {
	"max_hp": Color("52cc52ff"),
	"attack": Color(0.8, 0.32, 0.32, 1.0),
	"defense": Color(0.32, 0.528, 0.8, 1.0),
	"agility": Color(0.8, 0.8, 0.32, 1.0),
	"technique": Color(0.8, 0.32, 0.76, 1.0)
}

@export var max_hp:float;
@export var attack:float;
@export var defense:float;
@export var agility:float;
@export var technique:float;

@export var move_speed:float=200;

static func stat_colored_name(stat:String, close_tag:bool=true)->String:
	var color:String = stat_colors[stat].to_html();
	var string:String = "[color=" + color + "]" + stat.capitalize();
	if close_tag:
		string += "[/color]";
	return string;
	

const stat_descriptions = {
	"max_hp": "The unit's total HP at the start of battle.",
	"attack": "The damage dealt by weapons and skills. (some units and some weapons deal no damage)",
	"defense": "Reduces the damage taken by the unit.",
	"agility": "Reduces the cooldown of the player's weapon and units' skills.",
	"technique": "Improves special effects in modules and units' skills."
}

const player_level_stat_gains:Dictionary[String, float] = {
	## put this on player as nodes just like fighterbases?
	"max_hp":20,
	"attack":5,
	"defense":1,
	"agility":.5,
	"technique":.25
}

const player_stats_per_point:Dictionary[String, float] = {
	"max_hp":25,
	"attack":5,
	"defense":2.5,
	"agility":.5,
	"technique":.5
}



static func exp_for_next_level(current_level:int)->int:
	return (current_level + 1) ** 2;


const technique_mechanic_multipliers = {
	## fraction of itself that a technique scaled value gains when amplified by each point technique
	"stun":.05, 
	## TODO make stun duration tech scaling get diminishing returns bc rn stuns 
	## are either gonna be useless or units will be permastunning after a certain point in the game
	"stat_change":.2,
	"heal":.1,
	"damage":.1,
	"knockback":.1
}
const agility_yield_breakpoints = {
	## how much of a percentage of cooldown reduction each indifividual agility
	## point will give
	5.0:.025, ## 2.5% attack speed per point until 5
	30.0:.025, ## 1% until 30
	50.0:.005, ## 0.5% until 50
	100.0:.001 ## 0.1% until 100
	## dont think there's any way to get past 100 agility rn?
}
static func agility_cooldown_reduction(initial_cooldown:float, target_agility:float)->float:
	var previous_point:int = 0;
	var frac:float = 0.0
	for point:float in agility_yield_breakpoints.keys():
		if target_agility > point:
			frac += agility_yield_breakpoints[point] * (point - previous_point);
			previous_point = point
		else:
			frac += agility_yield_breakpoints[point] * (target_agility - previous_point)
	return initial_cooldown * frac

static func technique_scaled_value(value:float, source_technique:float, mechanic:String, custom_multiplier:float = 1.0)->float:
	if mechanic in technique_mechanic_multipliers:
		return value + value * source_technique * technique_mechanic_multipliers[mechanic];
	else:
		return value + value * source_technique * custom_multiplier;

static func technique_scaled_damage(damage:float, fighter:ActiveFighter)->float:
	var final_damage:float = technique_scaled_value(damage, fighter.technique, "damage");
	return final_damage 
	
