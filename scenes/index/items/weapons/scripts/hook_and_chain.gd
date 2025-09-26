extends Weapon

func get_description()->String:
	return "Stab the enemy in front of you.\nAlternative fire: Shoots the hook, damaging, stunning the first enemy it hits and pulling in front of you.";

const size_x = 4;
const size_y = 1;

const rarity = 3;

func use(alt:bool=false)->void:
	if alt:
		throw_line();

func throw_line()->void:
	pass
		
