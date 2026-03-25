extends "res://global/combat/combat_mechanics.gd"


func shoot_projectile(projectile:Projectile, source:ActiveFighter, hit_callback:Variant)->Projectile:
	var target_direction:Vector2;
	if source is PlayerFighter:
		
		target_direction = Entities.player_fighter.global_position.direction_to(Entities.player_fighter.get_global_mouse_position())
	elif source is NpcFighter:
		target_direction = source.global_position.direction_to(source.target_fighter.global_position);
	
	var shot:Projectile = projectile.shoot(target_direction);

	if hit_callback is Callable:
		shot.hit.connect(hit_callback);
	elif hit_callback is Array:
		for c:Callable in hit_callback:
			shot.hit.connect(c);
	return shot;
		

func aoe_damage(source:ActiveFighter, hit_scan:Area2D = source.base.hit_scan, hard_value:float=0.0, quiet:bool=false)->void:
	## HIT SCAN NEEDS TO BE POSITIONED IN WINDUP
	## simply damages all valid targets within the hit scan which may take different shapes
	for area:Area2D in hit_scan.get_overlapping_areas():
		assert(area is HurtBox);
		var target:CombatEntity = area.source;
		deal_damage(source, target, hard_value, quiet);


func aoe_status(source:ActiveFighter, status:Status=source.base.skill.status, hit_scan:Area2D=source.base.hit_scan, hard_value:float = 0)->void:
	var hurtboxes:Array[Area2D] = hit_scan.get_overlapping_areas();
	if source.target_fighter.hurtbox not in hurtboxes:
		hurtboxes.append(source.target_fighter.hurtbox)
	for area:Area2D in hurtboxes:
		assert(area is HurtBox);
		var target:CombatEntity = area.source;
		status.apply_on_target(target, hard_value)
	


func knock_back_target(source:ActiveFighter, target:ActiveFighter = source.target_fighter)->void:
	var direction:Vector2 = source.position.direction_to(target.position);
	var shift:Vector2 = direction * source.base.knock_back_distance;
	
	var target_collision_layer:int = target.ally_team.team_n;
	target.set_collision_layer_value(target_collision_layer, false);
	
	var tween:= create_tween();
	tween.tween_property(target, "position", target.position + shift, .25);
	tween.tween_callback(target.set_collision_layer_value.bind(target_collision_layer, true));

func lifesteal_heal(damage:float, _target:ActiveFighter, source:ActiveFighter)->void:
	## will stack heal floating texts in AOE vamp attacks
	var frac:float = source.base.lifesteal_frac;
	var to_heal:float = damage * frac;
	var amp:float = source.base.lifesteal_technique_amp;
	var final_heal:float = Scaling.technique_scaled_value(to_heal, source.technique, "", amp)
	Combat.heal_target(source, source, final_heal)
