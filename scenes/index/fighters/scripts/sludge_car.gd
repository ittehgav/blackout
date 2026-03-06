extends FighterBase

func full_skill_description(_unit:FighterUnit)->String:
	var no_dmg:String = Index.colored_text("no_dmg", "Deals no damage.");
	var shield_str:String = Index.colored_text("shield", "shield");
	var agi_str:String = Index.colored_text("agility", "agility");
	return "%s Slowly gains %s and reduces the %s of nearby enemies, the higher the shield, the wider the debuff area."%[no_dmg, shield_str, agi_str];
