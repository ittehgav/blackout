extends Accessory;

const size_x = 4;
const size_y = 2;

const rarity = 3

func get_description()->String:
	var description:String = super();
	description += "Doubles the wearer's " + CombatStats.stat_colored_name("technique") + " and " + CombatStats.stat_colored_name("agility") + "."
	return description;
