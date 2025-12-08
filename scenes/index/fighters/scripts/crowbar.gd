extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var damage_string:String = Index.colored_text("attack", unit.final_stat("attack"));
	return "High attack speed. Deals %s to the nearest enemy." % [damage_string]
	
