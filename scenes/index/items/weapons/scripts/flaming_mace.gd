extends Weapon

const rarity = 2;

const size_x = 2;
const size_y = 4;

func get_description()->String:
	var cost_str:String = ammo_cost_string();
	var damage_str:String = damage_string();
	return "Consumes %s to swing, hitting enemies causes an explosion, dealing %s to all enemies hit."%[cost_str, damage_str]
