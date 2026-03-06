extends FighterBase

func full_skill_description(_unit:FighterUnit)->String:
	var malaise:String = Index.colored_text("debuff", "Malaise");
	return "Bites the nearest enemy and applies %s, which temporarily reduces random stats every second."%[malaise];
