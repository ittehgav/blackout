extends "res://global/combat/combat_mechanics.gd"


func shoot_projectile(projectile:Projectile, source:ActiveFighter, hit_callback:Variant)->Projectile:
	var target_direction:Vector2;
	if source is PlayerFighter:
		
		target_direction = Entities.player_fighter.global_position.direction_to(Entities.player_fighter.get_global_mouse_position())
	elif source is NpcFighter:
		target_direction = source.global_position.direction_to(source.target_unit.global_position);
	
	var shot:Projectile = projectile.shoot(target_direction);

	if hit_callback is Callable:
		shot.hit.connect(hit_callback);
	elif hit_callback is Array:
		for c:Callable in hit_callback:
			shot.hit.connect(c);
	return shot;
		

func aoe_damage(source:ActiveFighter, hit_scan:Area2D = source.base.hit_scan, modifier:Callable = Callable())->void:
	## HIT SCAN NEEDS TO BE POSITIONED IN WINDUP
	## simply damages all valid targets within the hit scan which may take different shapes
	for area:Area2D in hit_scan.get_overlapping_areas():
		assert(area is HurtBox);
		var target:ActiveFighter = area.fighter;
		source.catch_hit_target(target);
		deal_damage(source, target, modifier);

func aoe_heal(source:ActiveFighter, value:float=Scaling.technique_scaled_value(source.base.heal_value, source.technique, "heal"),
				hit_scan:Area2D=source.base.hit_scan)->void:
	var targets:Array[Node2D] = hit_scan.get_overlapping_bodies();
	for target in targets:
		if source is NpcFighter:
			source.catch_hit_target(target);
		heal_unit(source, target, value)


func aoe_status(source:ActiveFighter, status:Status=source.base.status, hit_scan:Area2D=source.base.hit_scan, hard_value:float = 0)->void:
	var hurtboxes:Array[Area2D] = hit_scan.get_overlapping_areas();
	if source.target_unit.hurtbox not in hurtboxes:
		hurtboxes.append(source.target_unit.hurtbox)
	for area:Area2D in hurtboxes:
		assert(area is HurtBox);
		var target:ActiveFighter = area.fighter;
		status.apply_on_target(target, hard_value)
	


func set_aoe_aim(source:NpcFighter)->void:
	var shape:Shape2D = source.base.hit_scan.get_node("shape").shape;
	if shape is CircleShape2D:
		## may want to do circle AOEs that aren't centered in target?
		source.base.hit_scan.global_position = source.target_unit.global_position;
	elif shape is SegmentShape2D:
		var angle:float = source.position.angle_to_point(source.target_unit.position)
		source.base.hit_scan.global_rotation = angle
	elif shape is RectangleShape2D:
		source.base.hit_scan.global_rotation = source.position.angle_to_point(source.target_unit.position);
		source.base.hit_scan.global_position = source.target_unit.global_position;


func set_windup_angle(fighter:NpcFighter)->void:
	if Entities.arena.battle_over:
		return
	const base_rotation = 20;
	const rotation_deadzone = 50;
	var target_position:Vector2=fighter.target_unit.global_position;
	if target_position.y < fighter.global_position.y - rotation_deadzone:
		## TARGET ABOVE UNIT
		if fighter.base.scale.x > 0:
			## TARGET TO THE RIGHT OF UNIT
			fighter.base.rotation_degrees = -base_rotation 
		else:
			## TARGET TO THE LEFT OF UNIT
			fighter.base.rotation_degrees = base_rotation;
	if target_position.y > fighter.global_position.y + rotation_deadzone:
		## TARGET BELOW UNIT
		if fighter.base.scale.x > 0:
			## TARGET TO THE RIGHT OF UNIT
			fighter.base.rotation_degrees = base_rotation;
		else:
			## TARGET TO THE LEFT OF UNIT
			fighter.base.rotation_degrees = -base_rotation

func knock_back_target(source:ActiveFighter, target:ActiveFighter = source.target_unit)->void:
	var direction:Vector2 = source.position.direction_to(target.position);
	var shift:Vector2 = direction * source.base.knock_back_distance;
	
	var target_collision_layer:int = target.ally_team.team_n;
	target.set_collision_layer_value(target_collision_layer, false);
	
	var tween:= create_tween();
	tween.tween_property(target, "position", target.position + shift, .25);
	tween.tween_callback(target.set_collision_layer_value.bind(target_collision_layer, true));
