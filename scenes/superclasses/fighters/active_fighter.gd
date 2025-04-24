extends CharacterBody2D;

class_name ActiveFighter;

signal shield_gained(source:ActiveFighter, value:float);
signal damage_blocked(source:ActiveFighter, value:float)
signal damage_taken(damage:float);
signal healing_received(value:float);
signal death(killer:ActiveFighter);
signal stat_changed(stat:String);

signal status_applied(source:ActiveFighter, data:Dictionary);
signal status_removed(status_type:String, data:Dictionary)

var in_player_team:bool;



## make a more comprehensive form of extending activeFighter?
## right now base can exclusively serve as the sprite and data from npcFighter bases
@export var base:FighterBase;
@export var timers:Node;
## player node just gets one for now
@export var npc_sfx:AudioStreamPlayer2D;

var ally_team:Team;
var enemy_team:Team;

var stun_stack:int = 0;
var stunned:bool;

## combat stats (will get more complicated when it needs to)
var max_hp:float;
var hp:float;
var shield:float = 0;

var attack:float;
var defense:float;
var agility:float;
var technique:float;

var move_speed:float = 220.0;
