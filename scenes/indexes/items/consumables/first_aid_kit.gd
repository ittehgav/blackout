extends Consumable;

const rarity = 1;

const description = "Instantly restores a KO'd unit.";

func use_item()->bool:
	## when KO'd units are a thing, this will check for them and return false if there's none
	return false;
