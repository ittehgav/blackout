extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var attack_str:String = Index.colored_text("attack", "attack");
	var damage_str:String = Index.colored_text("attack", unit.final_stat("attack"), " damage");
	return "Slams the nearest enemy, dealing % and applying an %s debuff."%[damage_str, attack_str];
