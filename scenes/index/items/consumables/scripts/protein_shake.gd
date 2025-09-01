extends Consumable

const size_x = 1;
const size_y = 2;

const rarity = 1;

func get_description()->String:
	return "Use to permanently increase a [u]Bodybuilder's[/u] "+Index.stat_colored_name("max_hp") + " and " + Index.stat_colored_name("attack") + '.';
