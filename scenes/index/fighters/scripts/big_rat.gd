extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.colored_text("attack", unit.final_stat("attack"), " damage");
	var damage_buff_str:String = str(Scaling.technique_scaled_value(skill.status.value, unit.final_stat("technique"), "stat_change"))
	return "Bites the nearest enemy, dealing %s and applies and increases its own attack by %s for the rest of the battle."%[damage_str, damage_buff_str];
