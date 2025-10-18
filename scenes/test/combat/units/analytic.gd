extends Control

@export var level_label:Label;
@export var dps_label:Label;

var total_damage_dealt:float = 0;
var start_time:float;

var fighter:ActiveFighter

func attach_to_fighter(target:ActiveFighter)->void:
	start_time = Time.get_unix_time_from_system() 
	fighter = target
	level_label.text = "Level: " + str(target.level)
	
	fighter.damage_dealt.connect(log_damage)
	reparent(fighter.overlay.floating_icon_anchor)
	position = Vector2(0, -100)

func log_damage(damage:float, _target:ActiveFighter)->void:
	total_damage_dealt += damage

 


func refresh() -> void:
	var time_elapsed:float = Time.get_unix_time_from_system()  - start_time;
	dps_label.text = "DPS: " + str(snapped(total_damage_dealt/time_elapsed, .01))
