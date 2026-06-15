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

	for area:Area2D in hurtboxes:
		assert(area is HurtBox);
		var target:CombatEntity = area.source;
		status.apply_on_target(target, hard_value)
	





func aoe_knockback(source:ActiveFighter, hit_scan:Area2D = source.base.hit_scan,\
					strength:int = source.base.skill.knockback_strength)->void:
	var hurtboxes:Array[Area2D] = hit_scan.get_overlapping_areas();
	for area:Area2D in hurtboxes:
		assert(area is HurtBox);
		var target:CombatEntity = area.source
		knock_back_target(source, target, strength);

func radial_knockback(source:ActiveFighter, hit_scan:Area2D=source.base.hit_scan,\
						strength:int=source.base.skill.knockback_strength)->void:
	var hurtboxes:Array[Area2D] = hit_scan.get_overlapping_areas();
	for area:Area2D in hurtboxes:
		assert(area is HurtBox);
		var target:CombatEntity = area.source;
		var direction:Vector2 = hit_scan.global_position.direction_to(target.global_position);
		knock_back_target(source, target, strength, Vector2.ZERO, direction)
func flying_collision(t1:CombatEntity, t2:CombatEntity)->void:
	if t2 == t1.knockback_source:return
	var collision_velocity:float = t1.velocity.distance_to(Vector2.ZERO);
	t1.knockback_tween.kill();
	finish_flight(t1)
	if collision_velocity < 100:
		return
	else:
		collision_damage(t1.knockback_source, t1, t2)
		
	if collision_velocity < 1000:
		## just deals damage to both and stops
		t1.velocity = Vector2.ZERO;
	elif collision_velocity < 1500:
		## deals damage to both and send second one flying
		t1.velocity = Vector2.ZERO;
		var direction:Vector2 = t1.position.direction_to(t2.position)
		knock_back_target(t1.knockback_source, t2, 1, direction*t1.velocity.length()/2)
	else:
		pass
