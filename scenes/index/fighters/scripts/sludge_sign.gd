extends FighterBase

func full_skill_description(_unit:FighterUnit)->String:
	var attack_str:String = Index.colored_text("attack", "attack");
	return "Slams the nearest enemy, applying an %s debuff."%[attack_str];
