extends Node2D
class_name NpcFighterTest

## TEST SCENES:
## GET ADDED INTO ARENA TEAMS AS SINGLE COMPONENTS
## PUTS A SAMPLE OF THE UNIT INTO ON ITS TEAM'S NODE AND THE DUMMY ON THE 
## ON THE ENEMY
## GLOBAL TRANSFORM IS INTERITED right?
@onready var team:Team = get_parent();

@export var unit:FighterUnit;
@export var dummies:Array[FighterUnit]

@export var analytic:Control

func _ready()->void:
	for dummy_unit:FighterUnit in dummies:
		dummy_unit.setup();
		var dummy_fighter:NpcFighter = team.enemy_team.generate_fighter(dummy_unit);
		dummy_fighter.global_position = dummy_unit.global_position;
		connect_test_signals(dummy_fighter)
	
	var unit_fighter:NpcFighter = team.generate_fighter(unit);
	unit_fighter.global_position = unit.global_position;
	connect_test_signals(unit_fighter)
	analytic.attach_to_fighter(unit_fighter)
	
	hide();

func connect_test_signals(fighter:NpcFighter)->void:
	fighter.damage_dealt.connect(log_damage_dealt.bind(fighter))
	fighter.skill_used.connect(log_skill_used.bind(fighter));

	fighter.target_changed.connect(log_target_changed.bind(fighter))
	
	fighter.skill_hit.connect(log_skill_hit.bind(fighter));
	fighter.damage_blocked.connect(log_dmg_blocked.bind(fighter));

	fighter.damage_taken.connect(log_dmg_taken.bind(fighter));
	fighter.death.connect(log_death.bind(fighter));
	fighter.healing_received.connect(log_healing_received.bind(fighter));
	fighter.shield_gained.connect(log_shield_gained.bind(fighter));
	fighter.stat_changed.connect(log_stat_changed.bind(fighter));
	fighter.status_applied.connect(log_status_applied.bind(fighter))
	fighter.status_removed.connect(log_status_removed.bind(fighter));
	
func log_damage_dealt(damage:float, target:ActiveFighter, signal_source:NpcFighter)->void:
	print(signal_source.base.name + " " + str(damage) + " dmg dealt to " + target.base.name)

func log_skill_used(signal_source:ActiveFighter)->void:
	print(signal_source.base.name + " skill used");

func log_target_changed(signal_source:ActiveFighter)->void:
	print(signal_source.base.name + " target changed")

func log_skill_hit(target_hit:ActiveFighter, signal_source:ActiveFighter)->void:
	print(signal_source.base.name + " skill hit " + target_hit.name);

func log_dmg_blocked(signal_source:ActiveFighter)->void:
	print(signal_source.base.name + "damage blocked")

func log_dmg_taken(damage:float, source:ActiveFighter, signal_source:ActiveFighter)->void:
	print(signal_source.base.name +" "+ str(damage) +" damage taken from " + source.name)

func log_death(killer:ActiveFighter, signal_source:ActiveFighter)->void:
	print(signal_source.base.name + " killed by " + killer.name);

func log_healing_received(amount:float, signal_source:ActiveFighter)->void:
	print(str(amount) + " healing gained by " + signal_source.base.name);

func log_shield_gained(source:ActiveFighter, value:float, signal_source:ActiveFighter)->void:
	print(signal_source.base.name + " " +str(value) + " shield gained from " + source.name);

func log_stat_changed(stat:String, signal_source:ActiveFighter)->void:
	print(signal_source.base.name + " " + stat + " changed");

func log_status_applied(source:ActiveFighter, data:Dictionary, signal_source:ActiveFighter)->void:
	print(signal_source.base.name + " " + data.type + " applied by " + source.name);

func log_status_removed(status_type:String, _data:Dictionary, signal_source:ActiveFighter)->void:
	print(signal_source.base.name + " " + status_type + " removed")
	
