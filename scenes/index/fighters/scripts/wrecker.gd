extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var damage:String = Index.colored_text("attack", unit.final_stat("attack"), " damage");
	var debuff:float = Scaling.technique_scaled_value(skill.status.value, unit.final_stat("technique"), "stat_change");
	var debuff_str:String = Index.colored_text("technique", debuff, " defense");
	var final_string:String = "Throws a powerful punch, dealing %s to the nearest enemy and making them lose %s for the rest of the fight."%[damage, debuff_str];
	return final_string;
