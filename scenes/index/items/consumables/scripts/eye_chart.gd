extends Consumable

const size_x = 2;
const size_y = 2;

const rarity = 3;

func get_description()->String:
	return "Use to permanently increase the "+Index.stat_colored_name("agility") + " of a [u]scientist[/u] in your party by 3.";
	
	
	
func use_on_unit(target:FighterUnit)->void:
	target.modifier_stats.agility += 3;
