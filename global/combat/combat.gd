extends "res://global/combat/combat_mechanics.gd"


func shoot_projectile(projectile:Projectile, source:ActiveFighter, hit_callback:Variant)->Projectile:
	var target_direction:Vector2;
	if source is PlayerFighter:
		target_direction = Entities.player_fighter.global_position.direction_to(Entities.arena.get_global_mouse_position())
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
	for target:Node2D in hit_scan.get_overlapping_bodies():
		if source is NpcFighter:
			source.catch_hit_target(target);
		deal_damage(source, target, modifier);

func aoe_heal(source:ActiveFighter, value:float=Scaling.technique_scaled_value(source.base.heal_value, source.technique, "heal"),
hit_scan:Area2D=source.base.hit_scan)->void:
	var targets:Array[Node2D] = hit_scan.get_overlapping_bodies();
	for target in targets:
		if source is NpcFighter:
			source.catch_hit_target(target);

		heal_unit(source, target, value)
	

func aoe_stun(source:ActiveFighter, hit_scan:Area2D = source.base.hit_scan)->void:
	var targets:Array[Node2D] = hit_scan.get_overlapping_bodies();
	for target in targets:
		if source is NpcFighter:
			source.catch_hit_target(target);
		stun_target(source, target)


func self_stat_buff(source:ActiveFighter)->void:
	## TODO make stat buffs/debuffs apply in individual calls and the npcFighter
	##  node will break them down based on data from the base
	for stat:String in source.base.stats_to_buff:
			var value:float = source.base.stat_buff_values[stat];
			value = Scaling.technique_scaled_value(value, source.technique, "stat_buff")
			apply_stat_change(source, source, value, stat)

func aoe_stat_buff(source:ActiveFighter, stat:String, frac:float)->void:
	var targets:Array[Node2D] = source.hit_scan.get_overlapping_bodies();
	for target in targets:
		if source is NpcFighter:
			source.catch_hit_target(target);

		var value:float = Scaling.technique_scaled_value((target[stat] * frac), source.technique, "stat_buff");
		apply_stat_change(source, target, value, stat);
		
func aoe_taunt(source:ActiveFighter, hit_scan:Area2D = source.base.hit_scan, duration:float = 3)->void:
	var targets:Array[Node2D] = hit_scan.get_overlapping_bodies();
	for unit in targets:
		if source is NpcFighter:
			source.catch_hit_target(unit)
		if unit is NpcFighter:
			taunt_target(source, unit, duration);

func taunt_target(source:ActiveFighter, target:ActiveFighter, duration:float )->void:
	Statuses.apply_status(source, target, "taunt", duration )

func aoe_stat_debuff(source:ActiveFighter, percentage:bool=false, hit_scan:Area2D = source.base.hit_scan)->void:
	## TODO make this work the same way as aoe buff
	var targets:Array[Node2D] = hit_scan.get_overlapping_bodies();
	for unit in targets:
		if source is NpcFighter:
			source.catch_hit_target(unit);

		for stat:String in source.base.stats_to_debuff:
			## stat debuff values are multiplied by - 1 here
			var value:float;
			if percentage:
				var fraction:float = (unit[stat]/100) * source.base.stat_debuff_values[stat];
				value = -Scaling.technique_scaled_value(fraction, source.technique, "stat_debuff");
			else:
				value = -Scaling.technique_scaled_value(source.base.stat_debuff_values[stat], source.technique, "stat_debuff")
			apply_stat_change(source, unit, value, stat);

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
