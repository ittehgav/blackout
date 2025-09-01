extends Node



func level_up_stats(unit:FighterUnit, level:int=1)->void:
	## when the game starts, this loads every level of a given unit,
	## otherwise it runs the moment the unit levels, to update its new stats
	for tag:String in unit.base.tags:
		var gains:Dictionary = tag_stats_per_level(tag)
		for key:String in gains.keys():
			unit.stats[key] += gains[key] * level
	if "no_damage" in unit.base:
		unit.stats.attack = 0;



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
	
	for tag:String in unit.base.tags:
		match tag:
			## tags are more or less of equal value
			## the additional tag the unit gets when they 
			## level is the main reason leveling units is so powerful
			"juggernaut":
				## juggernaut - tank with focus on DEF
				unit.stats.max_hp += 100;
				unit.stats.attack += 5;
				unit.stats.defense += 10;
				
			"bodybuilder":
				## bodybuilder - tank with focus on HP
				unit.stats.max_hp += 150;
				unit.stats.attack += 5;
				unit.stats.defense += 5;
				
			"brawler":
				## brawler - still tanky with a slight bias towards attack
				unit.stats.max_hp += 75;
				unit.stats.attack += 7;
				unit.stats.defense += 5;
				
			"mechanic":
				## mechanic - tanky with a slight focus on technique 
				## (doesn't really show in this function)
				unit.stats.max_hp += 75;
				unit.stats.attack += 7;
				unit.stats.defense += 7.5;
				
			"disruptor":
				## disruptor - mid-range, focus on technique
				unit.stats.max_hp += 50;
				unit.stats.attack += 5;
				unit.stats.defense += 3;
				
			"hunter":
				## hunter - squishy, fully focused on damage
				unit.stats.max_hp += 50;
				unit.stats.attack += 10;
				unit.stats.defense += 2;
				
			"scientist":
				## scientist - squishy, focus on technique
				unit.stats.max_hp += 50;
				unit.stats.attack += 5;
				unit.stats.defense += 1;
				
			"doctor":
				unit.stats.max_hp += 75;
				unit.stats.attack += 10;
				unit.stats.defense += 3;
				
			"cyborg":
				## cyborg - low HP, high defense and ATK
				unit.stats.max_hp += 50
				unit.stats.attack += 7
				unit.stats.defense += 15;
			_:
				printerr("MISSIGNTAGA ", tag)

func tag_stats_per_level(tag:String)->Dictionary:
	## will the difference between some technique and no technique feel huge?
	## some tags can be straight up better than others?
	var dict:= {};
	match tag:
		"juggernaut":
			dict.max_hp = 50;
			dict.attack = 2;
			dict.defense = 4;
			
			dict.agility = 1
			dict.technique = .1
		"brawler":
			dict.max_hp = 40;
			dict.attack = 5;
			dict.defense = 2
			
			dict.agility = 1.5
			dict.technique = .1
		"hunter":
			dict.max_hp = 10;
			dict.attack = 10;
			dict.defense = .5;
			
			dict.agility = 1.5;
			dict.technique = .125
		"disruptor":
			dict.max_hp = 15;
			dict.attack = 3;
			dict.defense = .5;
			
			dict.agility = .75;
			dict.technique = .15
		"scientist":
			dict.max_hp = 10;
			dict.attack = 5;
			dict.defense = .5;
			
			dict.agility = 1
			dict.technique = .15;
		"mechanic":
			dict.max_hp = 25;
			dict.attack = 5;
			dict.defense = 1.5;
			
			dict.agility = 1.25
			dict.technique = .125
		"bodybuilder":
			dict.max_hp = 75;
			dict.attack = 3;
			dict.defense = 2;
			
			dict.agility = 1
			dict.technique = .1
		"doctor":
			dict.max_hp = 20;
			dict.attack = 1;
			dict.defense = .5;
			
			dict.agility = 1
			dict.technique = .15;
		"cyborg":
			dict.max_hp = 20;
			dict.attack = 10;
			dict.defense = 3;
			
			dict.agility = 1.5
			dict.technique = .15
	return dict;
	
func tag_upkeep_costs(tag:String)->Dictionary:
	var costs:Dictionary[String, int];
	match tag:
		"juggernaut":
			costs = {
				"food":2,
				"juice":2
			}
		"brawler":
			costs = {
				"food":2,
				"juice":2
			}
		"hunter":
			costs = {
				"scrap":1,
				"food":2
			}
		"disruptor":
			costs = {
				"scrap":1,
				"fuel":2
			}
		"scientist":
			costs = {
				"juice":2,
				"fuel":2
			}
		"mechanic":
			costs = {
				"fuel":2,
				"scrap":1
			}
		"bodybuilder":
			costs = {
				"food":2,
				"juice": 2
			}
		"doctor":
			costs = {
				"food":2,
				"scrap":1
			}
		"cyborg":
			costs = {
				"scrap":1,
				"fuel":2
			}
	
	return costs
	
func unit_upkeep_money_cost(level:int)->int:
	var cost:int = level * level;
	if level > 2:
		cost /= ceil(float(level)/2);
	return cost
	
	


func exp_for_next_level(current_level:int)->int:
	return (current_level + 1) ** 2;
	
var event_stat_value_multipliers:Dictionary[String, float] = {
	"max_hp": 100,
	"attack": 10,
	"defense": 5,
	"agility":1,
	"technique":.15
}

var player_stats_per_point:Dictionary[String, float] = {
	"max_hp":25,
	"attack":5,
	"defense":2.5,
	"agility":1,
	"technique":.5
}
	
const agility_yield_breakpoints = {
	## how much of a percentage of cooldown reduction each indifividual agility
	## point will give
	10:1.5,
	30:1,
	50:.75,
	100:.5
}

const technique_mechanic_multipliers = {
	"stun":.1,
	"stat_buff":.2,
	"stat_debuff":.2,
	"heal":.25,
	"damage":.5
}

func technique_scaled_value(value:float, source_technique:float, mechanic:String, custom_multiplier:float = 1.0)->float:
	if mechanic in technique_mechanic_multipliers:
		return value + value * source_technique * technique_mechanic_multipliers[mechanic];
	else:
		return value + value * source_technique * custom_multiplier;
