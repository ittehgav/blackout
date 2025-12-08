extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var damage:float = damage_modifier(unit.final_stat("attack"), unit);
	var damage_str:String = Index.colored_text("attack", damage, " damage");
	var final_string:String = "Shoots a powerful bolt, dealing %s to all enemies in a straight line."%[damage_str];
	return final_string;

func damage_modifier(damage:float, unit:FighterUnit=null)->float:
	if not unit:
		return Scaling.technique_scaled_value(damage, fighter.technique, "damage")
	else:
		return Scaling.technique_scaled_value(damage, unit.stats.technique, "damage")
