extends Node;
class_name AllyDamageTally

var source:NpcFighter;

var damage_tally:Dictionary[CombatEntity, int]
var sorted:Array[CombatEntity]
var last_ally_index:int = -1;

func _ready() -> void:
	await source.ally_team.all_units_loaded;

	start_tally();
	source.ally_damage_tally = self; 
	## setting reference here so it
	## doesnt try to catch the target 
	## befgore setup

func start_tally()->void:
	for f:ActiveFighter in source.ally_team.fighters:
		track_fighter_hp(f)

func track_fighter_hp(f:ActiveFighter)->void:
	damage_tally[f] = 0;
	sorted.append(f)
	last_ally_index += 1;
	
	f.damage_taken.connect(fighter_damage_taken.bind(f))
	f.healing_received.connect(fighter_healed.bind(f))
	f.death.connect(fighter_died.bind(f))

func fighter_damage_taken(damage:float, _source:ActiveFighter, _quiet:bool, fighter:ActiveFighter)->void:
	damage_tally[fighter] += damage
	var i:int = sorted.find(fighter);
	while i != 0:
		var ally:ActiveFighter = sorted[i-1]
		if damage_tally[fighter] > damage_tally[ally]:
			sorted[i] = ally;
			sorted[i-1] = fighter;
			i -= 1;
		else:
			break
	
func fighter_healed(value:float, _quiet:bool, fighter:ActiveFighter)->void:
	damage_tally[fighter] -= value
	var i:int = sorted.find(fighter);
	while i != last_ally_index:
		var ally:ActiveFighter = sorted[i + 1];
		if damage_tally[fighter] < damage_tally[ally]:
			sorted[i] = ally;
			sorted[i + 1] = fighter;
			i += 1;
		else:
			break;
func fighter_died(_killer:ActiveFighter, fighter:ActiveFighter)->void:
	damage_tally.erase(fighter);
	sorted.erase(fighter)
