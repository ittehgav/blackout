extends ActiveUnit;

class_name ActiveFighter;

signal damage_dealt(damage:float, target:ActiveFighter)
## right now just for dps metrics but very possible to be useful for other stuff later?
signal shield_gained(source:ActiveFighter, value:float);
signal damage_blocked(source:ActiveFighter, value:float)
signal damage_taken(damage:float, source:ActiveFighter);
signal healing_received(value:float);
signal death(killer:ActiveFighter);
signal stat_changed(stat:String);

signal status_applied(source:ActiveFighter, status:Status);
signal status_removed(status:Status);


## used to prevent multiple death signals when getting hit by multiple 
## lethal blows at the exact same time
var dead:bool=false;

## make a more comprehensive form of extending activeFighter?
## right now base can exclusively serve as the sprite and data from npcFighter bases
@export var base:FighterBase;
@export var timers:Node;
@export var statuses:Node;

@export var initial_stats:CombatStats
@export var stat_modifiers:CombatStats;
@export var stat_multipliers:CombatStats

@export var hurtbox:Area2D;


## keys to access specific statuses more easily from sources
## KEYS ARE THE NAMES OF THE STATUS
var special_statuses:Dictionary[String, Status];


var ally_team:Team;
var enemy_team:Team;

var stun_stack:int = 0;
var stunned:bool;

## combat stats (will get more complicated when it needs to)
var level:int;
## storing level (right now) only for the forbidden mask thingy

var max_hp:float;
var hp:float;
var shield:float = 0;

var attack:float;
var defense:float;
var agility:float;
var technique:float;


var hit_targets:Array[ActiveFighter]


func catch_hit_target(hit_unit:ActiveFighter)->void:
	if not hit_unit in hit_targets:
		hit_targets.append(hit_unit);
		
func refresh_all_stats()->void:
	for stat:String in Index.all_combat_stats:
		refresh_stat(stat)

func refresh_stat(stat:String)->void:
	## player weapon change is applied to modifiers and refreshed when needed
	self[stat] = (initial_stats[stat] + stat_modifiers[stat]) * stat_multipliers[stat]

func nearest_enemy()->ActiveFighter:
	var nearest:ActiveFighter;
	var nearest_distance:int = 0;
	for fighter:ActiveFighter in enemy_team.units:
		var distance:float = position.distance_to(fighter.position);
		if not nearest or distance < nearest_distance:
			nearest = fighter;
			nearest_distance = distance;
	return nearest;
