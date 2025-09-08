extends Accessory

const size_x = 4;
const size_y = 2;

const rarity = 3;


func get_description()->String:
	var description:String = super();
	description += "\nThe wearer deals 50% damage back to melee units.";
	return description;
