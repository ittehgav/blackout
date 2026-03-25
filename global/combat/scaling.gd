extends Node


func level_up_player_stats()->void:
	var target:CombatStats = Entities.player.stats;
	
	for stat:String in Index.all_combat_stats:
		target[stat] += player_level_stat_gains[stat]


var player_level_stat_gains:Dictionary[String, float] = {
	"max_hp":20,
	"attack":5,
	"defense":1,
	"agility":.5,
	"technique":.25
}
	
func unit_upkeep_money_cost(level:int)->int:
	var cost:int = level * level;
	if level > 2:
		cost /= ceil(float(level)/2);
	return cost


func exp_for_next_level(current_level:int)->int:
	return (current_level + 1) ** 2;
	

var player_stats_per_point:Dictionary[String, float] = {
	"max_hp":25,
	"attack":5,
	"defense":2.5,
	"agility":.5,
	"technique":.5
}
	

const technique_mechanic_multipliers = {
	## fraction of itself that a technique scaled value gains when amplified by each point technique
	"stun":.05, 
	## TODO make stun duration tech scaling get diminishing returns bc rn stuns 
	## are either gonna be useless or units will be permastunning after a certain point in the game
	"stat_change":.2,
	"heal":.25,
	"damage":.1
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
func agility_cooldown_reduction(initial_cooldown:float, target_agility:float)->float:
	var previous_point:int = 0;
	var frac:float = 0.0
	for point:float in agility_yield_breakpoints.keys():
		if target_agility > point:
			frac += agility_yield_breakpoints[point] * (point - previous_point);
			previous_point = point
		else:
			frac += agility_yield_breakpoints[point] * (target_agility - previous_point)
	return initial_cooldown * frac

func technique_scaled_value(value:float, source_technique:float, mechanic:String, custom_multiplier:float = 1.0)->float:
	if mechanic in technique_mechanic_multipliers:
		return value + value * source_technique * technique_mechanic_multipliers[mechanic];
	else:
		return value + value * source_technique * custom_multiplier;

func technique_scaled_damage(damage:float, fighter:ActiveFighter)->float:
	var final_damage:float = technique_scaled_value(damage, fighter.technique, "damage");
	return final_damage 
