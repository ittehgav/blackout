extends Consumable

const size_x = 2;
const size_y = 1;

const rarity = 2;

func get_description()->String:
	return "Use to gain a random amount of " + Index.resource_colored_name("food")+"."
