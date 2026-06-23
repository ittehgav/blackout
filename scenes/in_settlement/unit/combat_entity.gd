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
signal knocked_back(source:ActiveFighter, strength:int);

signal death(killer:ActiveFighter);
## ONLY FOR RECALCULATING STAT MECHANICS, VFX/SFX ARE ON STATUS_APPLIED SIGNALS
signal stat_changed(stat:String);

signal status_removed(status:Status);

enum WeightClass{light, medium, heavy}
@export var weight_class:WeightClass=WeightClass.medium;

enum BodyType {flesh, metal, wood};
@export var hurtbox:Area2D;
@export var collision_scan:Area2D;

@export var body_type:BodyType;

@export var statuses:Node;

var stun_stack:int = 0;
var stunned:bool;
var flying:bool;

## set every time a knockback is applied to unit
## assigned as source for all damage/signals 
## emitted by the knockback collisions
var knockback_source:ActiveFighter;
var knockback_tween:Tween;



## combat stats (will get more complicated when it needs to)
var level:int = 5;
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
	## idk the secto function dont catch 7 properly
	## and this is still simpler than making an if to catch all 8 sectors
	var direction_sector:int = get_sector_full(angle)
	
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
	
const first_sector_margin = -7*PI/8
const sector_margin_step = PI/4

func get_sector_full(angle: float) -> int:
	## not all units here will be isometric 3D
	var sector:int = -2;
	var margin:float = first_sector_margin;
	while angle > margin:
		sector += 1;
		margin += sector_margin_step;
	## returns 0 if either angle < first sector margin or it it's 8
	if sector == -2:
		return 6
	if sector == -1:
		return 7
	return sector;


func die(killer:ActiveFighter)->void:
	dead = true;
	
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 0, .7);
	tween.parallel().tween_property(self, "modulate:v", 0, .7)
	tween.tween_callback(queue_free)
	
	death.emit(killer)

func _on_collision_scan_area_entered(area: Area2D) -> void:
	assert(area is CollisionScan);
	## only happens when a unit is sent flying and collides
	## CollisionScans are always identical to the hurtbox
	Combat.flying_collision(self, area.source)

	
