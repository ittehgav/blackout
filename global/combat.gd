extends "res://global/combat_mechanics.gd"


func shoot_projectile(projectile:Projectile, source:ActiveFighter, hit_callback:Variant)->void:
	var target_direction:Vector2;
	if source is InFightPlayer:
		target_direction = Entities.in_fight_player.global_position.direction_to(Entities.arena.get_global_mouse_position())
	elif source is NpcFighter:
		target_direction = source.global_position.direction_to(source.target_unit.global_position);
	
	var shot:Projectile = projectile.shoot(target_direction);

	if hit_callback is Callable:
		shot.hit.connect(hit_callback);
	elif hit_callback is Array:
		for c:Callable in hit_callback:
			shot.hit.connect(c);
		

func aoe_damage(source:ActiveFighter)->void:
	## simply damages all valid targets within the hit scan which may take different shapes
	for target:Node2D in source.hit_scan.get_overlapping_bodies():
		if source is NpcFighter:
			source.catch_hit_target(target);
			
		deal_damage(source, target);

func aoe_heal(source:ActiveFighter, value:float)->void:
	var targets:Array[Node2D] = source.hit_scan.get_overlapping_bodies();
	for target in targets:
		if source is NpcFighter:
			source.catch_hit_target(target);

		heal_unit(source, target, value)
	

func aoe_stun(source:ActiveFighter)->void:
	var targets:Array[Node2D] = source.hit_scan.get_overlapping_bodies();
	for target in targets:
		if source is NpcFighter:
			source.catch_hit_target(target);
			
		stun_target(source, target)


func self_stat_buff(source:ActiveFighter)->void:
	## TODO make stat buffs/debuffs apply in individual calls and the npcFighter
	##  node will break them down based on data from the base
	for stat:String in source.base.stats_to_buff:
			var value:float = source.base.stat_buff_values[stat] * source.technique;
			apply_stat_change(source, source, value, stat)

func aoe_stat_buff(source:ActiveFighter, stat:String, frac:float)->void:
	var targets:Array[Node2D] = source.hit_scan.get_overlapping_bodies();
	for target in targets:
		if source is NpcFighter:
			source.catch_hit_target(target);

		var value:float = (target[stat] * frac) * source.technique;
		apply_stat_change(source, target, value, stat);
		

func aoe_stat_debuff(source:ActiveFighter)->void:
	## TODO make this work the same way as aoe buff
	var targets:Array[Node2D] = source.hit_scan.get_overlapping_bodies();
	for unit in targets:
		if source is NpcFighter:
			source.catch_hit_target(unit);

		for stat:String in source.base.stats_to_debuff:
			## stat debuff values are multiplied by - 1 here
			var value:float = source.base.stat_debuff_values[stat] * -source.technique
			apply_stat_change(source, unit, value, stat);
