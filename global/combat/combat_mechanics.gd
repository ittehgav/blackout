extends RefCounted

static func deal_damage(source:ActiveFighter, target:CombatEntity=source.target_fighter, hard_value:float=0, quiet:bool=false)->void:
	if not is_instance_valid(source) or not is_instance_valid(target):
		return
	source.catch_hit_target(target);
	var damage:float;
	if not hard_value:
		damage = source.damage_modifier.call(source.attack, source);
	else:
		## hard value only overrides the source's attack stat, 
		## not the modifier function that may come in
		damage = hard_value;

	var mitigation:float = defense_mitigation(target);
	damage -= damage * mitigation;
	if target.shield:
		target.shield -= damage;
		if target.shield < 0:
			var shield_overkill:float = -target.shield;
			target.hp -= shield_overkill;
			target.shield = 0;
	
			source.damage_dealt.emit(damage, target)
			target.damage_taken.emit(shield_overkill, source, quiet);
			if target.hp <= 0 and not target.dead:
				target.die(source)
		else:
			source.damage_dealt.emit(damage, target)
			target.damage_blocked.emit(source, damage, quiet);
	else:
		target.hp -= damage;

		source.damage_dealt.emit(damage, target)
		target.damage_taken.emit(damage, source, quiet)
		
		if target.hp <= 0 and not target.dead:
			target.die(source)


static func heal_target(source:ActiveFighter, target:CombatEntity, value:float)->void:
	## technique applied in call above this one bc theres gonna be multiple
	## heal sources and some will scale with other stuff too
	if not is_instance_valid(source) or not is_instance_valid(target):
		return
		
	source.catch_hit_target(target);
	
	target.hp += value;
	if target.hp > target.max_hp:
		target.hp = target.max_hp;

	target.healing_received.emit(value)



static func shield_target(source:ActiveFighter, target:CombatEntity, value:float, quiet:bool=false)->void:
	if not is_instance_valid(source) or not is_instance_valid(target):
		return
	target.shield += value;
	target.shield_gained.emit(source, value, quiet);



const def_mitigation_breakpoints = {
	## DEF value has diminishing returns, each breakpoint makes the value of each 
	## subsequent DEF point yield less damage mitigation
	## PERCENTAGE POINTS OF DMG MITIGATED
	20.0:1,
	50.0:.5,
	100.0:.25,
	200.0:.2
}

## after 200, every 100 def points make the next 100 yield half as much, towards infinity
const excess_def_falloff_divider = 2;
## value the player gets from the first 200 points of defense
const base_excess_mitigation = 42.5

static func defense_mitigation(source:CombatEntity)->float:
	var def_left:float = source.defense;
	var total_mitigation:float = 0.0
	var previous_point:float=0;

	if source.defense < 200:
		for point:float in def_mitigation_breakpoints.keys():
			var point_range:float = point - previous_point;
			if def_left > point_range:
				def_left -= point - previous_point;
				total_mitigation += (point - previous_point) * def_mitigation_breakpoints[point];
				previous_point = point
			else:
				total_mitigation += def_left * def_mitigation_breakpoints[point]
				break;
	else:
		def_left -= 200;
		total_mitigation += base_excess_mitigation;
		var point_value:float = def_mitigation_breakpoints[200.0];
		
		while def_left > 100:
			def_left -= 100
			total_mitigation += 100 * point_value;
			point_value /= excess_def_falloff_divider;
		
		total_mitigation += def_left * point_value

	## mitigation = pecentage reduction to damage
	## (only by defense stat rn)
	return total_mitigation/100


static func turn_ellusive(fighter:ActiveFighter, duration:float)->void:
	var team_n:int;
	if fighter.get_collision_layer_value(1) == true:
		team_n = 1;
	else:
		team_n = 2;
	fighter.set_collision_layer_value(team_n, false)
	await fighter.get_tree().create_timer(duration).timeout;
	fighter.set_collision_layer_value(team_n, true)


static func shoot_projectile(projectile:Projectile, source:ActiveFighter, hit_callback:Variant)->Projectile:
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
		

static func knock_back_target(source:ActiveFighter, target:CombatEntity = source.target_fighter,\
						strength:int=source.base.skill.knockback_strength,
						override_velocity:Vector2 = Vector2.ZERO,
						override_direction:Vector2 = Vector2.ZERO)->void:
	assert(strength);
	## catches not setting a skillcomponents's kb strength
	source.catch_hit_target(target);
	const base_distance = 15
	target.knockback_source = source;
	var level_gap:float = float(source.level)/float(target.level);
	var velocity:Vector2;
	if override_velocity == Vector2.ZERO:
		var final_distance:float = base_distance * level_gap * strength
		var direction:Vector2 = source.position.direction_to(target.position);
		if override_direction != Vector2.ZERO:
			direction = override_direction
		velocity = direction * final_distance * 20;
	else:
		velocity = override_velocity * level_gap
	
	var duration:float = .2 * strength
	match target.weight_class:
		CombatEntity.WeightClass.light:
			velocity *= 1.25
			duration *= 1.1
		## medium weight = no change
		CombatEntity.WeightClass.heavy:
			velocity *= .5
			duration *= .75
		
	
	target.flying = true;
	target.collision_scan.monitoring = true
	target.velocity = velocity;
	
	if target.knockback_tween and target.knockback_tween.is_running():
		target.knockback_tween.kill();
	
	target.knocked_back.emit(source, strength);
	
	target.knockback_tween = target.create_tween();
	target.knockback_tween.tween_property(target, "velocity", Vector2.ZERO, duration)
	target.knockback_tween.tween_callback(finish_flight.call_deferred.bind(target))

static func collision_damage(source:ActiveFighter, t1:ActiveFighter, t2:ActiveFighter)->void:
	deal_damage(source, t1);
	if t2 in source.enemy_team.fighters:
		deal_damage(source, t2);

static func finish_flight(target:ActiveFighter)->void:
	target.flying = false
	target.collision_scan.monitoring = false
