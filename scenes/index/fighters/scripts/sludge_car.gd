extends FighterBase

const base_shield = 50.0;

func full_skill_description(_unit:FighterUnit)->String:
	var no_dmg:String = Index.colored_text("no_dmg", "Deals no damage.");
	var shield_str:String = Index.colored_text("shield", "shield");
	var agi_str:String = Index.colored_text("agility", "agility");
	return "%s Every second, gains %s and reduces the %s of nearby enemies. The more enemies are affected, the more shield it gains."%[no_dmg, shield_str, agi_str];

func special_skill_effect()->void:
	var shield:float = base_shield * (float(len(fighter.hit_targets))/2.0);
	Combat.shield_target(fighter, fighter, shield);
