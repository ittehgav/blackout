extends Node


func initiate_unit_stats(unit:FighterUnit)->void:
	## gives the stats to a FighterUnit
	## ONLY THE INITIAL VALUE FROM THEIR BASE'S TAGS
	## will be ran when the node is first loaded and when it evolves, where it will 
	## retroactively gain the bonuses for the current level
	for tag:String in unit.base.tags:
		match tag:
			"juggernaut":
				unit.stats.max_hp += 100;
				unit.stats.defense += 20;
				unit.stats.attack += 10;
			"brawler":
				unit.stats.max_hp += 75;
				unit.stats.defense += 15;
				unit.stats.attack += 15;
			"hunter":
				unit.stats.max_hp += 25;
				unit.stats.defense += 0;
				unit.stats.attack += 30;
			"disruptor":
				unit.stats.max_hp+= 25;
				unit.stats.defense += 5;
				unit.stats.attack += 5;
			"healer":
				unit.stats.max_hp += 50;
				unit.stats.defense += 5;
			"scientist":
				unit.stats.max_hp+= 25;
				unit.stats.defense += 5;
				unit.stats.attack += 10;
			"mechanic":
				unit.stats.max_hp+= 50;
				unit.stats.defense += 5;
				unit.stats.attack += 10;
			"bodybuilder":
				unit.stats.max_hp+= 75;
				unit.stats.defense += 5;
				unit.stats.attack += 10;
			"doctor":
				unit.stats.max_hp += 25;
				unit.stats.defense += 5;
				unit.stats.attack += 10;
			"cyborg":
				unit.stats.max_hp += 25
				unit.stats.defense += 10;
				unit.stats.attack += 25


func level_up_stats(unit:FighterUnit)->void:
	for tag:String in unit.base.tags:
		var gains:Dictionary = tag_stats_per_level(tag)
		for key:String in gains.keys():
			unit.stats[key] += gains[key]

func tag_stats_per_level(tag:String)->Dictionary:
	## will the difference between some technique and no technique feel huge?
	## some tags can be straight up better than others?
	var dict:= {};
	match tag:
		"juggernaut":
			dict.max_hp = 25;
			dict.defense = 10;
			dict.attack = 5;
		"brawler":
			dict.max_hp = 15;
			dict.defense = 7
			dict.attack = 10;
		"hunter":
			dict.max_hp = 5;
			dict.defense = 2;
			dict.attack = 20;
			dict.technique = .05
		"disruptor":
			dict.max_hp = 5;
			dict.defense = 2;
			dict.attack = 5;
			dict.technique = .125
		"healer":
			dict.max_hp = 10;
			dict.defense = 5;
			dict.attack = 0;
			dict.technique = .125
		
		"scientist":
			dict.max_hp = 5;
			dict.defense = 5;
			dict.attack = 10;
			dict.technique = .2;
		"mechanic":
			dict.max_hp = 10;
			dict.defense = 10;
			dict.attack = 10;
			dict.technique = .125
		"bodybuilder":
			dict.max_hp = 20;
			dict.defense = 5;
			dict.attack = 10;
		"doctor":
			dict.max_hp = 5;
			dict.defense = 2;
			dict.attack = 0;
			dict.technique = .2;
		"cyborg":
			dict.max_hp = 15;
			dict.defense = 10;
			dict.attack = 10;
			dict.technique = .125
	return dict;


func exp_for_next_level(current_level:int)->int:
	return (current_level + 1) ^ 2;
	
