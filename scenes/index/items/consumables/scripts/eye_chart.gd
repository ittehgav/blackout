extends Consumable

const size_x = 2;
const size_y = 2;

const rarity = 2;

func get_description()->String:
	return "Use to increase the "+Index.stat_colored_name("agility") + " of a [u]scientist[/u] in your party.";
	
	
