extends Sprite2D;

class_name FighterBase

signal skill_finished;
## right now just a fighterbase that doesn't move

const MELEE_RANGE = 50

const MID_RANGE = 300;
const LONG_RANGE = 750;



@export var fighter:ActiveFighter;
@export var animation_player:AnimationPlayer
@export var hit_scan:Area2D;

@export var hard_stats:CombatStats;

var sample:bool=false;
## feels like i'd rather keep this tracked even though right now there's only one option
@export_enum("nearest_enemy") var target_type:String = "nearest_enemy";


@export var tags:Array[String] = [
	## TODO UNIFY THE TAGS TO A SINGLE SOURCE
	"bodybuilder",
	"brawler",
	"cyborg",
	"scientist",
	 "mechanic",
	"hunter",
	"juggernaut",
	"disruptor"
]

@export_group("misc")
@export var idle_animation_root:String = "fighter_base"
@export var special:bool=false;
@export var need_target:bool=true;
@export var global_hit_scan:bool=false;
@export var no_damage:bool=false


func fighter_died()->Tween:
	modulate.v = .5;
	modulate.a = .5;
	var tween:Tween = Tweens.ui_fade_out(self, false, .3)
	tween.parallel().tween_property(self, "position:x", 20, .3);
	return tween;


func fighter_started_moving()->void:
	## can override these for base-specific walk cycles i suppose
	if animation_player.current_animation == "fighter_base/idle":
		animation_player.play("fighter_base/walk");
	else:
		animation_player.queue("fighter_base/walk")

func fighter_stopped_moving()->void:
	rotation = 0;
	if animation_player.current_animation == "fighter_base/walk":
		animation_player.play(idle_animation_root+"/idle");
	else:
		animation_player.queue(idle_animation_root+"/idle")

func final_skill_cooldown(unit:FighterUnit)->float:
	var base_cooldown:float = self["skill_cooldown"]
	return base_cooldown - Scaling.agility_cooldown_reduction(base_cooldown, unit.final_stats().agility);

func skill()->void:
	printerr("skillmissing");

func skill_effect()->void:
	printerr("skilleffectmissing")

func full_skill_description(_unit:FighterUnit)->String:
	return "skillescriptionmissing"

func clear_for_sample()->void:
	sample = true
	## so i can keep track of where these are called
	for c:Node in get_children():
		if c is CanvasItem:
			c.hide();

func skill_impact()->void:
	## cancels the skill when the battle's over or the target died during the animation
	if not fighter or not fighter.target_unit or fighter.dead or fighter.target_unit.dead:
		return
	skill_effect()
