extends FighterBase;

func full_skill_description(_unit:FighterUnit)->String:
	return "Moves towards enemies and detonates itself, dealing damage and reducing their defense.";
	

func special_skill_effect()->void:
	Combat.deal_damage(fighter, fighter, 9999, true)
