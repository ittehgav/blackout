extends Weapon

const rarity = 3;

const size_x = 3;
const size_y = 2;

func get_description()->String:
	var ammo_str:String = ammo_cost_string()
	var damage_str:String = damage_string();
	return "Consumes %s to fire a bomb that burns the ground in a circular area, burning enemies inside it for %s per second."%[ammo_str, damage_str]
