extends FighterBase

func full_skill_description(_unit:FighterUnit)->String:
	var aoe_str:String = Index.colored_text("attack", "area damage");
	return "Flings itself into enemies, dealing %s where it lands."%[aoe_str];
