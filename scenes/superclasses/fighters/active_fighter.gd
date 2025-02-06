extends CharacterBody2D;

class_name ActiveFighter;

var ally_team:Array[Node];
var enemy_team:Array[Node];

@warning_ignore("unused_signal")
signal damage_taken(damage:float);
@warning_ignore("unused_signal")
signal healing_received(value:float);
@warning_ignore("unused_signal")
signal death(killer:ActiveFighter);
@warning_ignore("unused_signal")
signal status_applied(source:ActiveFighter, type:String);




@export var base:FighterBase;
@export var floating_icon_anchor:Node2D;

@export var stun_timer:Timer;

@export var timers:Node;
@export var status_timer:Timer;

## combat stats (will get more complicated when it needs to)
var max_hp:float;
var hp:float;
var attack:float;
var defense:float;
var move_speed:float = 500.0;

func update_overlay(_damage: float=0) -> void:
	var hp_label:Label = $overlay/hp;
	
	hp_label.text = str(hp);
	if hp > max_hp/2:
		hp_label.modulate = Color.GREEN.darkened(.2);
	elif hp > max_hp/6:
		hp_label.modulate = Color.YELLOW.darkened(.2)
	else:
		hp_label.modulate = Color.RED;

func damage_overlay_shake(damage:float):
	var intensity:float = .1;
	if damage > max_hp/2:
		intensity = 1;
	elif damage > max_hp/3:
		intensity = .75;
	Tweens.damage_overlay_tween($overlay/hp, intensity);
