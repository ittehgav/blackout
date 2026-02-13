extends Sprite2D;

## will fully replace FighterBase eventually
class_name FighterBase

## range is now in cells rather than 2D space pixels
const MELEE_RANGE = 1;
const MID_RANGE = 6;
const LONG_RANGE = 10;

var fighter:ActiveFighter;
@export var hit_scan:Area2D;
@export var projectile:Projectile

@export var status:Status;
@export var skill:SkillComponent;

@export var animation_player:AnimationPlayer

## repeating this on the base scripts so movement/skill
## animations can be set for each individual base
## also animation players dont play too well with not 
## having the nodes right on top of them when you make the animations
signal started_moving;
signal stopped_moving;

func _ready()->void:
	if not self is PlayerFighterBase:
		## faster to reiterate than if i had to manually make the connections on each unit
		started_moving.connect(animation_player.play.bind("fighter_base/walk"))
		stopped_moving.connect(animation_player.play.bind("fighter_base/idle"))


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
	disruptor
}

func skill_windup()->void:
	animation_player.play("fighter_base/skill");
	await animation_player.animation_finished;
	animation_player.play("fighter_base/idle");
	skill.use()

@export var tags:Array[Tag]
func final_skill_cooldown(unit:FighterUnit)->float:
	var base_cooldown:float = skill.base_cooldown;
	return base_cooldown - Scaling.agility_cooldown_reduction(base_cooldown, unit.final_stats().agility);

func full_skill_description(_unit:FighterUnit)->String:
	## put this in the skill component as well?
	return "skillescriptionmissing"

func special_skill_effect()->void:
	printerr("MISSINGSPECIALSKILLEF")
#func damage_modifier(_damage:float, _unit:FighterUnit=null)->float:
	#printerr("MISSINGDMGMOD"); ## TODO make this abstract and less janky implementation of modifiers
	#return 0;

func fighter_died()->Tween:
	modulate.v = .5;
	modulate.a = .5;
	var tween:Tween = Tweens.ui_fade_out(self, false, .3)
	tween.parallel().tween_property(self, "position:x", 20, .3);
	return tween;
