extends FighterBase

func full_skill_description(_unit:FighterUnit)->String:
	var attack_str:String = Index.colored_text("attack", "attack")
	return "Wraps around an enemy, reducing their %s and dealing damage every second, will come off if stunned or taken heavy damage."%[attack_str]
