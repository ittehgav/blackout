@abstract
@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_follow.png")
class_name FighterBase
extends Sprite2D;

## will fully replace FighterBase eventually


## range is now in cells rather than 2D space pixels

const MELEE_RANGE = 1;
const MID_RANGE = 5;
const LONG_RANGE = 10;
enum SkillRange{
	melee_range=MELEE_RANGE,
	mid_range=MID_RANGE,
	long_range=LONG_RANGE
}
@export var skill:SkillComponent;

@warning_ignore("int_as_enum_without_cast")
@export var skill_range:SkillRange=MELEE_RANGE;

@export var animation_player:AnimationPlayer


var fighter:NpcFighter;

@export var tags:Array[Tag]

@export var evolutions:Array[FighterBase] = []


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

enum RecruitTag{
	bodybuilder = Tag.bodybuilder,
	brawler = Tag.brawler,
	cyborg = Tag.cyborg,
	scientist = Tag.scientist,
	mechanic = Tag.mechanic,
	freak = Tag.freak,
	juggernaut = Tag.juggernaut,
	disruptor = Tag.disruptor,
}

enum MonsterTag{
	toxic = Tag.toxic,
	pest = Tag.pest,
	reptile = Tag.reptile,
	rodent = Tag.rodent,
	sludge = Tag.sludge,
	insec = Tag.insect
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
		
@export_group("misc")
## stuff that won't be changed as often as the other stuff
@export_enum("recruit", "monster") var fighter_type:String = "recruit";
## where we can add other special types like bosses or more complex NPCs?
@export var body_type:CombatEntity.BodyType;

@export var hit_scan:Area2D;
@export var projectile:Projectile
@export var base_stats:CombatStats;
@export var stats_per_level:CombatStats;

@export var idle_animation_path:String = "fighter_base/idle"
@export var walk_animation_path:String = "fighter_base/walk"
@export var skill_animation_path:String = "fighter_base/skill"
signal started_moving;
signal stopped_moving;



func _ready()->void:
	if not self is PlayerFighterBase:
		if not fighter:
			## makes them take up less memory space?
			## make this happen before ready somehow?
			for c:Node in get_children():
				c.queue_free();
			return
		## faster to reiterate than if i had to manually make the connections on each unit
		started_moving.connect(on_started_moving)
		stopped_moving.connect(on_stopped_moving)


func on_started_moving()->void:
	if animation_player.current_animation != skill_animation_path:
		animation_player.play(walk_animation_path);

func on_stopped_moving()->void:
	if animation_player.current_animation != skill_animation_path:
		animation_player.play(idle_animation_path)

func post_skill_update()->void:
	if fighter.moving:
		animation_player.play(walk_animation_path);
	else:
		animation_player.play(idle_animation_path)

func skill_windup()->void:
	## overrideable not abstract
	animation_player.play(skill_animation_path);
	skill.use()
	if skill.instant_impact:
		skill.impact.emit();
	else:
		await animation_player.animation_finished;
	post_skill_update()

func final_skill_cooldown(unit:FighterUnit)->float:
	var base_cooldown:float = skill.base_cooldown;
	return base_cooldown - Scaling.agility_cooldown_reduction(base_cooldown, unit.final_stats().agility);

@abstract func full_skill_description(_unit:FighterUnit)->String;

func special_skill_effect()->void:
	## not abstract most units dont have it so its just a fallback
	## can be used to add vfx/sfx to skill start
	printerr("specialeffect missing")

func skill_impact()->void:
	## cant call it from skill node for whatever reason but this makes
	## it more modular
	## can be used to add special vfx/sfx to skill impact
	skill.impact.emit();



func proximity_sort(a:ActiveFighter, b:ActiveFighter)->bool:
	var ad:float = a.position.distance_to(fighter.position);
	var bd:float = b.position.distance_to(fighter.position);
	return ad < bd;
