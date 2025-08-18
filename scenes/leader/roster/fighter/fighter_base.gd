extends Sprite2D;

class_name FighterBase

signal skill_finished;
## right now just a fighterbase that doesn't move

@export var fighter:ActiveFighter;
@export var animation_player:AnimationPlayer
@export var hit_scan:Area2D;


@export var tags:Dictionary[String,bool] = {
	"bodybuilder":false,
	 "brawler":false,
	 "cyborg":false,
	 "scientist":false,
	 "mechanic":false,
	 "hunter":false,
	 "doctor":false, 
	"juggernaut":false,
	"disruptor":false
}

@export_group("misc")
@export var idle_animation_root:String = "fighter_base"
@export var special:bool=false;

@export var need_target:bool=true;

const MELEE_RANGE = 100

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
