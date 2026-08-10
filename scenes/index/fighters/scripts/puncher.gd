extends FighterBase;

const evolution_names = ["Slammer", "Wrecker"]

func full_skill_description(_unit:FighterUnit)->String:
	var final_string:String = "Punches the nearest enemy, damaging and sending them flying a short distance.";
	return final_string
