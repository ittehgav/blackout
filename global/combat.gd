extends "res://global/combat_mechanics.gd"


func skill_effect(source:ActiveFighter, effect_name:String)->void:
	match effect_name:
		"direct_damage":
			deal_damage(source, source.target_unit);
			if source is NpcFighter:
				source.catch_hit_target(source.target_unit)
					
		"aoe_damage":
			aoe_damage(source);
			
		"stun_target":
			stun_target(source, source.target_unit);
			
		"aoe_stun":
			aoe_stun(source);
			
		"self_stat_buff":
			self_stat_buff(source);
			if source is NpcFighter:
				source.catch_hit_target(source);
					
		"aoe_stat_debuff":
			aoe_stat_debuff(source);
			
		"special":
			source.base.special_skill();


func aoe_damage(source:ActiveFighter)->void:
	## simply damages all valid targets within the hit scan which may take different shapes
	var enemy_team:Team = source.enemy_team;
	for target:Node2D in source.hit_scan.get_overlapping_bodies():
		if target in enemy_team.units:
			if source is NpcFighter:
				source.catch_hit_target(target);
			deal_damage(source, target);


func aoe_stun(source:ActiveFighter)->void:
	var targets:Array[Node2D] = source.hit_scan.get_overlapping_bodies();
	for target in targets:
		if source is NpcFighter:
			source.catch_hit_target(target);
		if target in source.enemy_team.units:
			stun_target(source, target)


func self_stat_buff(source:ActiveFighter)->void:
		for stat:String in source.base.stats_to_buff:
			match stat:
				"defense", "attack", "max_hp", "agility":
					var value:float = source.base.stat_buff_values[stat] * source.technique;
					apply_stat_change(source, source, value, stat)


func aoe_stat_debuff(source:ActiveFighter)->void:
	var targets:Array[Node2D] = source.hit_scan.get_overlapping_bodies();
	for unit in targets:
		if unit in source.enemy_team.units:

			if source is NpcFighter:
				source.catch_hit_target(unit);

			for stat:String in source.base.stats_to_debuff:
				## stat debuff values are multiplied by - 1 here
				var value:float = source.base.stat_debuff_values[stat] * source.technique * -1
				apply_stat_change(source, unit, value, stat);
							
