@abstract

class_name ActiveFighter;

extends CombatEntity;

signal damage_dealt(damage:float, target:ActiveFighter)
## right now just for dps metrics but very possible to be useful for other stuff later?


## make a more comprehensive form of extending activeFighter?
## right now base can exclusively serve as the sprite and data from npcFighter bases
@export var base:FighterBase; 
## ONLY FOR NPC FIGHTERS


@export var timers:Node;


@export var initial_stats:CombatStats
@export var stat_modifiers:CombatStats;
@export var stat_multipliers:CombatStats



var summon:bool=false;

var hit_targets:Array[CombatEntity]


func catch_hit_target(hit_figher:CombatEntity)->void:
	if not hit_figher in hit_targets:
		hit_targets.append(hit_figher);
		
func refresh_all_stats()->void:
	for stat:String in CombatStats.all_stats:
		refresh_stat(stat)

func refresh_stat(stat:String)->void:
	## player weapon change is applied to modifiers and refreshed when needed
	self[stat] = (initial_stats[stat] + stat_modifiers[stat]) * stat_multipliers[stat]

func nearest_enemy()->ActiveFighter:
	var nearest:ActiveFighter;
	var nearest_distance:int = 0;
	for fighter:ActiveFighter in enemy_team.fighters:
		var distance:float = position.distance_to(fighter.position);
		if not nearest or distance < nearest_distance:
			nearest = fighter;
			nearest_distance = distance;
	return nearest;


var damage_modifier:Callable = no_dmg_mod;
func no_dmg_mod(damage:float, _source:ActiveFighter)->float:
	## looks silly but easier than to add a bunch of conditioning to 
	## whether or not the source has a modifier
	## gets replaced when necessary by a real modifier at battle start
	return damage
