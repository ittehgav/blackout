extends Accessory

const size_x = 3;
const size_y = 2;

const rarity = 2

func get_description()->String:
	var description:String = super();
	description += "Doubles the wearer's " + CombatStats.stat_colored_name("technique") + ".";
	return description;
