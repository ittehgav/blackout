extends Node

class_name SkillComponent
## for now just mash these together on instances in the test scene
## eventually will be in the fighter base and replace a lot of 
## stuff that's currently just lines in their script

## try and keep these easy to transplant to NPCfighter
var npc_fighter:NpcFighter

@export var fighter:IsoFighter;



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
	## can't be done in animationplayer because it may
	## vary based on the way the unit is facing
	## player AFTER WINDUP
	lunge,
	recoil
}



@export var targetting:TargetType;
@export var effects:Array[Effect]
@export var tranform_visual:TransformVFX
@export var base_cooldown:float;

enum RangeOptions {
	melee = IsoBase.MELEE_RANGE,
	mid = IsoBase.MID_RANGE,
	long = IsoBase.LONG_RANGE
}

@export var skill_range:RangeOptions=RangeOptions.melee;

func impact()->void:
	for e:Effect in effects:
		match e:
			Effect.direct_damage:
				Combat.deal_damage(npc_fighter)
			Effect.direct_status:
				fighter.base.status.apply_on_target();
			
			Effect.aoe_damage:
				Combat.aoe_damage(npc_fighter);
			Effect.aoe_status:
				Combat.aoe_status(npc_fighter);
			
			Effect.knock_back:
				Combat.knock_back_target(npc_fighter);
			
			Effect.special:
				fighter.base.special_effect();
	play_transform_vfx()

func play_transform_vfx()->void:
	const tranform_movement = 30;
	match tranform_visual:
		TransformVFX.lunge:
			var direction:Vector2 = fighter.angle_to_target();
			fighter.sprite.offset = direction * tranform_movement;
			var tween:Tween = create_tween();
			tween.tween_property(fighter.sprite, "offset", Vector2.ZERO, .25);
		TransformVFX.recoil:
			var direction:Vector2 = fighter.angle_to_target();
			fighter.sprite.offset = direction * -tranform_movement;
			var tween:Tween = create_tween();
			tween.tween_property(fighter.sprite, "offset", Vector2.ZERO, .25);

				
			
