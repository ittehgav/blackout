extends Node

class_name SkillComponent
## for now just mash these together on instances in the test scene
## eventually will be in the fighter base and replace a lot of 
## stuff that's currently just lines in their script

## try and keep these easy to transplant to NPCfighter


@export var fighter:NpcFighter;

@export var need_target:bool=true;

@export var scan_enemies:bool=true;
@export var scan_allies:bool=false;
@export var position_lineup:bool=true;

## for anything other than damage/generic statuses, used in special skill which
## goes in the fighter base stript but it goes in the skillcomp node for consistency
## always scaled with technique but also gets resolved in special skill call
@export var base_special_values:Dictionary[String, float];
signal finished


enum TargetType {nearest_enemy}
enum Effect {
	## direct = apply to unit's target
	direct_damage,
	direct_status,
	
	## aoe = apply to all valid targets in unit's hit scan
	aoe_damage,
	aoe_status,

	## knock back effects are cool and i could put them on more 
	## people than just gravity
	knock_back,

	special
};

enum TransformVFX {
	## can't be done in animationplayer because it
	## varies based on the way the unit is facing
	## plays AFTER WINDUP
	lunge,
	recoil,
	grow
}

@export var modifiers:Dictionary[String, bool] = {
	"technique_scaled_damage":false
}

@export var targetting:TargetType;
@export var effects:Array[Effect]
@export var tranform_visual:TransformVFX
@export var base_cooldown:float;

enum RangeOptions {
	melee = FighterBase.MELEE_RANGE,
	mid = FighterBase.MID_RANGE,
	long = FighterBase.LONG_RANGE
}

@export var skill_range:RangeOptions=RangeOptions.melee;

func lineup()->void:
	if Effect.aoe_damage in effects or Effect.aoe_status in effects:
		line_up_hit_scan()
		## where projections will be lined up/tweened?

func line_up_hit_scan()->void:
	if position_lineup:
		fighter.base.hit_scan.global_position = fighter.target_unit.global_position;
	fighter.base.hit_scan.look_at(fighter.target_unit.global_position)

func use()->void:
	for e:Effect in effects:
		match e:
			Effect.direct_damage:
				Combat.deal_damage(fighter)
			Effect.direct_status:
				fighter.base.status.apply_on_target();
			Effect.aoe_damage:
				Combat.aoe_damage(fighter);
			Effect.aoe_status:
				Combat.aoe_status(fighter);
			Effect.knock_back:
				Combat.knock_back_target(fighter);
			Effect.special:
				fighter.base.special_skill_effect();
	play_transform_vfx()



func play_transform_vfx()->void:
	## transform/offset of fighter bases is reserved exclusively for this? 
	var tween:Tween = create_tween();
	const vfx_duration = .3
	const tranform_movement = 30;
	match tranform_visual:
		TransformVFX.lunge:
			var direction:Vector2 = fighter.angle_to_target();
			fighter.base.offset = direction * tranform_movement;
			tween.tween_property(fighter.base, "offset", Vector2.ZERO, vfx_duration);
		TransformVFX.recoil:
			var direction:Vector2 = fighter.angle_to_target();
			fighter.base.offset = direction * -tranform_movement;
			tween.tween_property(fighter.base, "offset", Vector2.ZERO, vfx_duration);
		TransformVFX.grow:
			## transform of fighter bases is reserved for 
			var original_scale:Vector2 = fighter.base.scale;
			fighter.base.scale *= 2;
			tween.tween_property(fighter.base, "scale", original_scale, vfx_duration)
	await tween.finished;
	finished.emit()
