extends Weapon

const rarity = 1;

const size_x = 1;
const size_y = 2;


func get_description()->String:
	var damage:String = damage_string();
	## TODO applies some sort of debuff?
	return "Deals %s to enemies in front of you."%[damage];


func apply_r1()->void:
	pass
func apply_r2()->void:
	pass
func apply_r3()->void:
	pass
