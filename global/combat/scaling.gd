extends Node



func level_up_stats(unit:FighterUnit, level:int=1)->void:
	## when the game starts, this loads every level of a given unit,
	## otherwise it runs the moment the unit levels, to update its new stats
	for tag:FighterBase.Tag in unit.base.tags:
		var gains:Dictionary = tag_stats_per_level(tag)
		for key:String in gains.keys():
			unit.stats[key] += gains[key] * level

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


func initiate_unit_stats(unit:FighterUnit)->void:
	## gives the stats to a FighterUnit
	## ONLY THE INITIAL VALUE FROM THEIR BASE'S TAGS
	## will be ran when the node is first loaded and when it evolves, where it will 
	## retroactively gain the bonuses for the current level
	for stat:String in Index.all_combat_stats:
		if stat == "technique":
			unit.stats[stat] = 1;
		else:
			unit.stats[stat] = 0;
	
	for tag:FighterBase.Tag in unit.base.tags:
		match tag:
			## tags are more or less of equal value
			## the additional tag the unit gets when they 
			## level is the main reason leveling units is so powerful
			FighterBase.Tag.juggernaut:
				## juggernaut - tank with focus on DEF
				unit.stats.max_hp += 100;
				unit.stats.attack += 5;
				unit.stats.defense += 10;
				
			FighterBase.Tag.bodybuilder:
				## bodybuilder - tank with focus on HP
				unit.stats.max_hp += 150;
				unit.stats.attack += 5;
				unit.stats.defense += 5;
				
			FighterBase.Tag.brawler:
				## brawler - still tanky with a slight bias towards attack
				unit.stats.max_hp += 75;
				unit.stats.attack += 7;
				unit.stats.defense += 5;
				
			FighterBase.Tag.mechanic:
				## mechanic - tanky with a slight focus on technique 
				## (doesn't really show in this function)
				unit.stats.max_hp += 75;
				unit.stats.attack += 7;
				unit.stats.defense += 7.5;
				
			FighterBase.Tag.disruptor:
				## disruptor - mid-range, focus on technique
				unit.stats.max_hp += 50;
				unit.stats.attack += 5;
				unit.stats.defense += 3;
				
			#FighterBase.Tag.hunter:
				### hunter - squishy, fully focused on damage
				#unit.stats.max_hp += 50;
				#unit.stats.attack += 10;
				#unit.stats.defense += 2;
				
			FighterBase.Tag.scientist:
				## scientist - squishy, focus on technique
				unit.stats.max_hp += 50;
				unit.stats.attack += 5;
				unit.stats.defense += 1;
				
			FighterBase.Tag.freak:
				unit.stats.max_hp += 75;
				unit.stats.attack += 10;
				unit.stats.defense += 3;
				
			FighterBase.Tag.cyborg:
				## cyborg - low HP, high defense and ATK
				unit.stats.max_hp += 50
				unit.stats.attack += 7
				unit.stats.defense += 15;
			_:
				printerr("MISSIGNTAGA ", str(tag))

func tag_stats_per_level(tag:FighterBase.Tag)->Dictionary:
	## will the difference between some technique and no technique feel huge?
	## some tags can be straight up better than others?
	var dict:= {};
	match tag:
		FighterBase.Tag.juggernaut:
			dict.max_hp = 50;
			dict.attack = 2;
			dict.defense = 3;
			
			dict.agility = .25
			dict.technique = .1
		FighterBase.Tag.brawler:
			dict.max_hp = 40;
			dict.attack = 5;
			dict.defense = 1.5
			
			dict.agility = .5
			dict.technique = .1
		FighterBase.Tag.freak:
			dict.max_hp = 10;
			dict.attack = 10;
			dict.defense = .5;
			
			dict.agility = .5;
			dict.technique = .125
		FighterBase.Tag.disruptor:
			dict.max_hp = 15;
			dict.attack = 3;
			dict.defense = .75;
			
			dict.agility = .35;
			dict.technique = .15
		FighterBase.Tag.scientist:
			dict.max_hp = 10;
			dict.attack = 5;
			dict.defense = .5;
			
			dict.agility = .25
			dict.technique = .5;
		FighterBase.Tag.mechanic:
			dict.max_hp = 25;
			dict.attack = 5;
			dict.defense = 1.25;
			
			dict.agility = .75
			dict.technique = .125
		FighterBase.Tag.bodybuilder:
			dict.max_hp = 75;
			dict.attack = 3;
			dict.defense = 1.75;
			
			dict.agility = .5
			dict.technique = .1

		FighterBase.Tag.cyborg:
			dict.max_hp = 20;
			dict.attack = 10;
			dict.defense = 2.5;
			
			dict.agility = 1
			dict.technique = .15
	return dict;

	
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
	"stun":.1,
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
