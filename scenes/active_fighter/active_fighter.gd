extends CharacterBody2D;

var ally_team:Array[Node];
var enemy_team:Array[Node];


@warning_ignore("unused_signal")
signal damage_taken(damage:float);
@warning_ignore("unused_signal")
signal death(killer:CharacterBody2D);
@warning_ignore("unused_signal")
signal status_applied(source:CharacterBody2D, type:String);

var move_speed:int = 500;

@export var base:Sprite2D;
@export var floating_icon_anchor:Node2D;

@export var stun_timer:Timer;

@export var timers:Node;
@export var status_timer:Timer;

## combat stats (will get more complicated when it needs to)
var max_hp:float;
var hp:float;
var attack:float;
var defense:float;

func damage_taken_vfx(_damage: float) -> void:
	Tweens.damage_blink(self);

func _on_death(_killer:CharacterBody2D)->void:
	ally_team.erase(self);
	
	var tween:Tween = Tweens.death_vfx(self);
	tween.tween_callback(queue_free)

func update_overlay(_damage: float=0) -> void:
	var hp_label:Label = $overlay/hp;
	
	hp_label.text = str(hp);
	if hp > max_hp/2:
		hp_label.modulate = Color.GREEN.darkened(.2);
	elif hp > max_hp/6:
		hp_label.modulate = Color.YELLOW.darkened(.2)
	else:
		hp_label.modulate = Color.RED;
