extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var damage_string:String = Index.colored_text("attack", Scaling.technique_scaled_value(unit.final_stat("attack"), unit.final_stat("technique"), "damage"));
	var technique_str:String = Index.colored_text("technique", "Technique");
	return "High attack speed. Deals %s to the nearest enemy, damage is improved by %s."\
	 % [damage_string, technique_str]
