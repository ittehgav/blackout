@abstract
class_name FighterBase
extends Sprite2D;

## will fully replace FighterBase eventually


## range is now in cells rather than 2D space pixels
const MELEE_RANGE = 2;
const MID_RANGE = 6;
const LONG_RANGE = 10;

@export var animation_player:AnimationPlayer
@export var skill:SkillComponent;

var fighter:ActiveFighter;
@export var hit_scan:Area2D;
@export var projectile:Projectile
@export var status:Status;


@export var tags:Array[Tag]
enum Tag {
	## just cv paste the old format if this becomes too much 
	## work for too little payoff?
	bodybuilder,
	brawler,
	cyborg,
	scientist,
	mechanic,
	freak,
	juggernaut,
	disruptor,
	
	## make monster tags separate eventually?
	## TODO make stat scaling for monster tags
	toxic,
	pest,
	reptile,
	rodent,
	sludge,
	insect
}
## repeating this on the base scripts so movement/skill
## animations can be set for each individual base
## also animation players dont play too well with not 
## having the nodes right on top of them when you make the animations

@export var movement:MovementPattern = MovementPattern.chase;
enum MovementPattern{
	chase, 
	## will go as close as possible to target unless they're in range and 
	## the next cell in the path moves them off their skill range
	hover,
	## will move towards target until they're in range and
	## run away if the target is 2(?) cells closer than the max range
	none
	## never moves
	## (but can still target and stuff?)
}

signal started_moving;
signal stopped_moving;

func _ready()->void:
	if not self is PlayerFighterBase:
		## faster to reiterate than if i had to manually make the connections on each unit
		started_moving.connect(on_started_moving)
		stopped_moving.connect(on_stopped_moving)

func on_started_moving()->void:
	if animation_player.current_animation != "fighter_base/skill":
		animation_player.play("fighter_base/walk");

func on_stopped_moving()->void:
	if animation_player.current_animation != "fighter_base/skill":
		animation_player.play('fighter_base/idle')


func skill_windup()->void:
	## overrideable not abstract
	animation_player.play("fighter_base/skill");
	skill.use()
	await animation_player.animation_finished;
	animation_player.play("fighter_base/idle");

func final_skill_cooldown(unit:FighterUnit)->float:
	var base_cooldown:float = skill.base_cooldown;
	return base_cooldown - Scaling.agility_cooldown_reduction(base_cooldown, unit.final_stats().agility);

@abstract func full_skill_description(_unit:FighterUnit)->String;

func special_skill_effect()->void:
	## not abstract most units dont have it so its just a fallback
	printerr("specialeffect missing")

func skill_impact()->void:
	## cant call it from skill node for whatever reason but this makes
	## it more modular
	skill.impact.emit();


#func damage_modifier(_damage:float, _unit:FighterUnit=null)->float:
	#printerr("MISSINGDMGMOD"); ## TODO make this abstract and less janky implementation of modifiers
	#return 0;

func fighter_died()->Tween:
	modulate.v = .5;
	modulate.a = .5;
	var tween:Tween = Tweens.ui_fade_out(self, false, .3)
	tween.parallel().tween_property(self, "position:x", 20, .3);
	return tween;
