extends Consumable

const size_x = 1
const size_y = 1;

const rarity = 1;

func get_description()->String:
	return "Use to double the price of an item."

func use_on_item(target:Item)->void:
	target.price_multiplier += 2;
