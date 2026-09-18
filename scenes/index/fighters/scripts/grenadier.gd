extends FighterBase

enum DetFX{ ## detonation effects
	radial_knockback, 
	agility_debuff,
	def_debuff,
	stun
}

@export var projection:Sprite2D;
@export var projection_animation:AnimationPlayer;

@export var detfx_colors:Dictionary[DetFX, Color]

func full_skill_description(_unit:FighterUnit)->String:
	return "Throws grenades at enemies, dealing damage and an additional random effect.";


func special_skill_effect()->void:
	var roll:DetFX = DetFX.values().pick_random();
	var c:Color = detfx_colors[roll];
	projection.self_modulate = c;
	var p := Combat.shoot_projectile(projectile, fighter, grenade_hit, detonation_effect.bind(roll))
	
	p.modulate = c;
	projection.global_position = fighter.target_fighter.global_position;
	var is_ally:bool=fighter.ally_team.team_n == 1;
	projection_animation.speed_scale = 1/p.flight_duration
	
	if is_ally:
		projection_animation.play("projection_ally");
	else:
		projection_animation.play("projection_enemy")
	
func grenade_hit(target:CombatEntity)->void:
	pass

func detonation_effect(target:Vector2, effect_roll:DetFX)->void:
	pass
