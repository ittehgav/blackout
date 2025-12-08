extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var dps:String = Index.colored_text("attack", unit.final_stat("attack"), " damage")
	var debuff:float = Scaling.technique_scaled_value(status.value, unit.final_stat("technique"), "stat_change");
	var debuff_str:String = Index.colored_text("technique", debuff, " attack reduction")
	var final_string:String = "Fires toxic gas on nearby enemies, dealing %s and applying a stacking %s."%[dps, debuff_str];
	return final_string
