extends FighterBase;

func full_skill_description(unit:FighterUnit)->String:
	var damage_string:String = Index.colored_text("attack", unit.final_stat("attack"), " damage")
	return "Stabs enemies, dealing %s to enemies in a straight line."%[damage_string];
