extends Node

class_name SkillComponent
## for now just mash these together on instances in the test scene
## eventually will be in the fighter base and replace a lot of 
## stuff that's currently just lines in their script

## try and keep these easy to transplant to NPCfighter
signal impact
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
	
	passive, ## TODO implement this
	## 0 cooldwn = necessarily passive ticker/other types of passive?
	special,
	
	self_status
};

enum TransformVFX {
	## can't be done in animationplayer because it
	## varies based on the way the unit is facing
	## plays AFTER WINDUP
	lunge,
	recoil,
	grow,
	none
}


enum RangeOptions {
	melee = FighterBase.MELEE_RANGE,
	mid = FighterBase.MID_RANGE,
	long = FighterBase.LONG_RANGE
}
var fighter:NpcFighter;



@export var targetting:TargetType;
@export var base_cooldown:float; ## TODO 0 cooldown = passive
@export var skill_range:RangeOptions=RangeOptions.melee;
@export var effects:Array[Effect]

@export var tranform_visual:TransformVFX


@export var instant_impact:bool=false;

@export var need_target:bool=true;

@export var scan_enemies:bool=true;
@export var scan_allies:bool=false;
@export var position_lineup:bool=true;

@export var status:Status;

## ONLY FOR ENEMY MOBS,
## projections generated dynamically based on the hitscan's shape
@export var aoe_projection:bool=true;
## for anything other than damage/generic statuses, used in special skill which
## goes in the fighter base script but it goes in the skillcomp node for consistency
## always scaled with technique but also gets resolved in special skill call
@export var special_aoe_projection:bool=false

@export_subgroup("special modifiers")

@export var technique_scaled_damage:bool=false;
## calls Scaling.technique_scaled_damage
## technique_scaled damage and own_damage_mod are mutually exclusive
## but maybe dont have to be?

@export var own_damage_modifier:bool=false;
## calls the damage_modifier method that needs to be in the base

@export var lifesteal:bool=false;
## needs the base to have a vamp and vamp_technique_amp properties

func lineup()->void:
	if Effect.aoe_damage in effects or Effect.aoe_status in effects:
		line_up_hit_scan()
		## where projections will be lined up/tweened?

func line_up_hit_scan()->void:
	if position_lineup:
		fighter.base.hit_scan.global_position = fighter.target_fighter.global_position;
	fighter.base.hit_scan.rotation = fighter.global_position.angle_to_point(fighter.target_fighter.global_position)

func use()->void:
	## may end up with stuff before impact as skill get more complex?
	await impact
	play_transform_vfx()
	for e:Effect in effects:
		match e:
			Effect.direct_damage:
				Combat.deal_damage(fighter)
			Effect.direct_status:
				status.apply_on_target();
			Effect.aoe_damage:
				Combat.aoe_damage(fighter);
			Effect.aoe_status:
				Combat.aoe_status(fighter);
			Effect.knock_back:
				Combat.knock_back_target(fighter);
			Effect.self_status:
				status.apply_on_target(fighter);
			Effect.special:
				fighter.base.special_skill_effect();


func play_transform_vfx()->void:
	## transform/offset of fighter bases is reserved exclusively for this? 
	## AFTER IMPACT
	var tween:Tween = create_tween();
	const vfx_duration = .3
	const tranform_movement = 30;
	match tranform_visual:
		## ALL TRANFORM VISUALS MUST EMIT THE IMPACT SIGNAL
		TransformVFX.lunge:
			var direction:Vector2 = fighter.direction_to_target;
			fighter.sprite.offset = direction * tranform_movement;
			tween.tween_property(fighter.sprite, "offset", Vector2.ZERO, vfx_duration);
		TransformVFX.recoil:
			var direction:Vector2 = fighter.direction_to_target;
			fighter.sprite.offset = direction * -tranform_movement;
			tween.tween_property(fighter.sprite, "offset", Vector2.ZERO, vfx_duration);
		TransformVFX.grow:
			## transform of fighter bases is reserved for 
			var original_scale:Vector2 = fighter.sprite.scale;
			fighter.sprite.scale *= 2;
			tween.tween_property(fighter.sprite, "scale", original_scale, vfx_duration)
	await tween.finished;
	finished.emit()
