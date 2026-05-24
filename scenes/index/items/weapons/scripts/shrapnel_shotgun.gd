extends Weapon

const rarity = 3;

const size_x = 4;
const size_y = 3;

func get_description()->String:
	var damage_str:String = damage_string();
	return "Consumes %s to deal %s to all enemies in a cone area in front of you."
