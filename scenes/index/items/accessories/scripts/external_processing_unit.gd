extends Accessory;

const size_x = 4;
const size_y = 2;

const rarity = 3

func get_description()->String:
	var description:String = super();
	description += "Doubles the wearer's " + Index.stat_colored_name("technique") + " and " + Index.stat_colored_name("agility") + "."
	return description;
