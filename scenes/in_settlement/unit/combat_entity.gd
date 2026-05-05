@abstract
@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/robot.png")
class_name CombatEntity

extends CharacterBody2D;

signal started_moving;
signal stopped_moving;


signal shield_gained(source:ActiveFighter, value:float, quiet:bool);
signal damage_blocked(source:ActiveFighter, value:float, quiet:bool)
signal damage_taken(damage:float, source:ActiveFighter, quiet:bool);
signal healing_received(value:float, quiet:bool);
signal status_applied(source:ActiveFighter, status:Status, quiet:bool);

signal death(killer:ActiveFighter);
## ONLY FOR RECALCULATING STAT MECHANICS, VFX/SFX ARE ON STATUS_APPLIED SIGNALS
signal stat_changed(stat:String);

signal status_removed(status:Status);

enum BodyType {flesh, metal, wood};
@export var hurtbox:Area2D;

@export var body_type:BodyType;

@export var statuses:Node;

var stun_stack:int = 0;
var stunned:bool;

## combat stats (will get more complicated when it needs to)
var level:int;
## storing level (right now) only for the forbidden mask thingy


## used to prevent multiple death signals when getting hit by multiple 
## lethal blows at the exact same time
var dead:bool=false;


@export var sprite:Sprite2D;

## combat stats will be in ActiveFighter
var move_speed:float = 500.0;
var ally_team:Team;
var enemy_team:Team;

@export var max_hp:float;
## ONLY USE EXPORTED VALUE FOR PROPS.
## final stats as are, get refreshed when modifications happen
## (on CombatEntity rather than ActiveFighter because it's easier
## to do this than to deal with all kinds of exceptions for props)
var attack:float;
var defense:float;
var agility:float;
var technique:float;

var hp:float;
var shield:float = 0;

var moving:bool=false;

func get_sector(angle: float) -> int:
	## not all units here will be isometric 3D
	var direction_sector:int = int(fposmod(angle + PI / 2, TAU) / (PI / 4)) % 8;
	if direction_sector == 0:
		## facing up
		## angle ~= -PI/2
		if angle > -PI/2:
			direction_sector = 1;
		else:
			direction_sector = 7
	elif direction_sector == 4:
		## facing down
		## angle ~= PI/2
		if angle < PI/2:
			direction_sector = 3;
		else:
			direction_sector = 5
	return direction_sector;
	

func die(killer:ActiveFighter)->void:
	dead = true;
	
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 0, .7);
	tween.parallel().tween_property(self, "modulate:v", 0, .7)
	tween.tween_callback(queue_free)
	
	death.emit(killer)
	
