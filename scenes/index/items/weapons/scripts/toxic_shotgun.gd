extends Weapon

const rarity = 3;

const size_x = 4;
const size_y = 3

func get_description()->String:
	var damage_str:String = damage_string();
	var cost_str:String = ammo_cost_string();
	return "Consumes %s to deal %s to enemies in a cone area and reduce their defense.";
	
