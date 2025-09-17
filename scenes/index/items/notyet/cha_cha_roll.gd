extends Consumable


const size_x = 2;
const size_y = 3;

const rarity = 3;

func get_description()->String:
	return "Use to get a random unit, 90% chance of a [color=grey]common[/color] unit, 9% chance of a [color=blue]rare[/color] unit and 1% chance of a [color=yellow]Legendary[/color] unit.";
	
