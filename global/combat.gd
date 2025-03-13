extends "res://global/combat_mechanics.gd"


func skill_effect(source:ActiveFighter, effect_name:String)->void:
	match effect_name:
		"direct_damage":
			deal_damage(source, source.target_unit);
		"aoe_damage":
			aoe_damage(source);
			
		"stun":
			stun_target(source, source.target_unit);
		"aoe_stun":
			aoe_stun(source);

		"self_buff":
			self_buff(source);
		"aoe_debuff":
			aoe_debuff(source);

		"special":
			source.base.special_skill();


func aoe_damage(source:ActiveFighter)->void:
	## simply damages all valid targets within the hit scan which may take different shapes
	for target in source.hit_scan.get_overlapping_bodies():
		if target in source.enemy_team.units:
			deal_damage(source, target);
			Tweens.damage_blink(target);


func aoe_stun(source:ActiveFighter)->void:
	var targets:Array[Node2D] = source.hit_scan.get_overlapping_bodies();
	for target in targets:
		if target in source.enemy_team.units:
			stun_target(source, target)


func self_buff(source)->void:
	match source.base.buff_type:
		"stat":
			for stat in source.base.stats_to_buff:
				match stat:
					"defense", "attack", "max_hp", "move_speed":
						var value:float = source.base.stat_buff_values[stat] * source.technique;
						apply_stat_change(source, source, value, stat)



func aoe_debuff(source:ActiveFighter)->void:
	var targets:Array[Node2D] = source.hit_scan.get_overlapping_bodies();
	match source.base.debuff_type:
		"stat":
			for unit in targets:
				if unit in source.enemy_team.units:
					for stat in source.base.stats_to_debuff:
						match stat:
							"defense", "attack", "max_hp", "move_speed":
								## stat debuff values are multiplied by - 1 here
								var value:float = source.base.stat_debuff_values[stat] * source.technique
								apply_stat_change(source, unit, value * -1, stat);
								
