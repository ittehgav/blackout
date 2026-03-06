extends FighterBase

func full_skill_description(_unit:FighterUnit)->String:
	var neutral: String = Index.colored_text("neutral", "Neutral Chrysalid");
	var chrysalid: String = Index.colored_text("neutral", "Chrysalid")
	return "Attempts to devour an enemy, turning them into a %s, if it survives until the end of combat, the unit gets converted into a %s and can hatch into a powerful unit."%[neutral, chrysalid];
