extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var damage:float = Scaling.technique_scaled_value(unit.final_stat("attack"), unit.final_stat("technique"), "damage");
	var damage_str:String = Index.colored_text("attack", damage, " damage");
	var technique_str:String = Index.colored_text("technique", "Technique")
	var final_string:String = "Shoots a powerful bolt, dealing %s to all enemies in a straight line, damage is amplified by %s."\
	%[damage_str, technique_str];
	return final_string;
