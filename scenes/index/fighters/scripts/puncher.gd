extends FighterBase;



func full_skill_description(unit:FighterUnit)->String:
	var damage:String = Index.colored_text("attack", unit.final_stat("attack"), " damage");
	var duration:float = Scaling.technique_scaled_value(skill.status.duration, unit.final_stat("technique"), "stun");
	var duration_str:String = Index.colored_text("technique", duration, " seconds");
	var final_string:String = "Punches the nearest enemy, dealing %s and stunning them for %s."%[damage, duration_str];
	return final_string
