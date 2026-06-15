extends CPUParticles2D

class_name Dust;

var source:ActiveFighter
@export var manual:bool=false;

func _ready()->void:
	## will be child of active fighter and detect context
	## and connect itself without any other nodes having to do anything
	if manual:return
	var parent:Node = get_parent();
	while not parent is ActiveFighter:
		## non-manual = started moving =
		## only in NPC fighter and player fighter
		parent = parent.get_parent();
		
	source = parent
	source.started_moving.connect(dust_animation)

func dust_animation(motion:Vector2=(source.velocity * -1).normalized())->void:
	if motion.x > 0:
		direction.x = 1;
	else:
		direction.x = -1;
	emitting = true;

const sector_v2s = {
	0: Vector2(0, -1),
	1: Vector2(1, -1),
	2: Vector2(1, 0),
	3: Vector2(1, 1),
	4: Vector2(0, 1),
	5: Vector2(-1, 1),
	6: Vector2(-1, 0),
	7: Vector2(-1, -1)
}


func skill_impact_dust(skill:SkillComponent)->void:
	## runs on skill impact so sprite will be lined up to motion
	var sector:int = skill.fighter.sprite.frame_coords.x
	match skill.transform_visual:
		SkillComponent.TransformVFX.lunge:
			direction = sector_v2s[sector] * -1;
		SkillComponent.TransformVFX.recoil:
			direction = sector_v2s[sector]
		SkillComponent.TransformVFX.grow:
			direction = Vector2.ZERO
	emitting = true

func setup_impact_dust(target:NpcFighter)->void:
	target.base.skill.impact.connect(skill_impact_dust.bind(target.base.skill));
	match target.base.skill.transform_visual:
		SkillComponent.TransformVFX.grow:
			amount = 100;
		_:
			amount = 30;
