extends Weapon

const rarity = 2;

const size_x = 2;
const size_y = 2;

func get_description()->String:
	var damage:String = Index.colored_text("attack", str(final_damage()) + " damage");
	return "On hit, shoots lightning, dealing %s to hit enemies." % [damage];
