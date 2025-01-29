extends "res://global/combat_mechanics.gd"



func skill_effect(source:CharacterBody2D, effect_name:String)->void:
	match effect_name:
		"aoe_damage":
			aoe_damage(source);
		"aoe_stun":
			aoe_stun(source);
		"direct_damage":
			deal_damage(source, source.target_unit);
		"self_buff":
			self_buff(source);
		"aoe_debuff":
			aoe_debuff(source);
		"special":
			source.base.special_skill(source);
	
func aoe_damage(source:CharacterBody2D)->void:
	## simply damages all valid targets within the hit scan which may take different shapes
	for target in source.hit_scan.get_overlapping_bodies():
		if target in source.enemy_team:
			deal_damage(source, target);
			Tweens.damage_blink(target);


func aoe_stun(source:CharacterBody2D)->void:
	var targets = source.hit_scan.get_overlapping_bodies();
	for target in targets:
		if target in source.enemy_team:
			stun_target(source, target)


func self_buff(source):
	match source.base.buff_type:
		"stat":
			for stat in source.base.stats_to_buff:
				match stat:
					"def":
						source.def += source.def_buff_value;
						source.status_applied.emit(source, "stat_up")
						## TODO: implement buff durations


func aoe_debuff(source:CharacterBody2D)->void:
	var targets = source.hit_scan.get_overlapping_bodies();
	match source.base.debuff_type:
		"stat":
			for unit in targets:
				if unit in source.enemy_team:
					for stat in source.base.stats_to_debuff:
						match stat:
							"defense", "attack", "max_hp", "move_speed":
								## stat debuff values are multiplied by - 1 here
								var value = source.base.stat_debuff_values[stat]
								apply_stat_change(source, unit, value * -1, stat);
								
