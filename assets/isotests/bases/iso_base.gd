extends Sprite2D;

## will fully replace FighterBase eventually
class_name IsoBase

## range is now in cells rather than 2D space pixels
const MELEE_RANGE = 1;
const MID_RANGE = 5;
const LONG_RANGE = 10;

var fighter:IsoFighter;
@export var hit_scan:Area2D;

@export var status:Status;
@export var skill:SkillComponent;


enum FighterBaseTag {
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

func final_skill_combat(unit:IsoFighter)->float:
	var base_cooldown:float = skill.base_cooldown;
	return base_cooldown - Scaling.agility_cooldown_reduction(base_cooldown, unit.final_stats().agility);

func full_skill_description(_unit:FighterUnit)->String:
	## put this in the skill component as well?
	return "skillescriptionmissing"
