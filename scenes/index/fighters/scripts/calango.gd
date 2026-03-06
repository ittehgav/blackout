extends FighterBase

func full_skill_description(_unit:FighterUnit)->String:
	var poison_str:String = Index.colored_text("debuff", "Poisoned")
	return "Sweeps its tail, hitting nearby enemies, then sheds the tail and throws it in a random location, enemies who touch the tail are %s, taking damage over time."%[poison_str]
