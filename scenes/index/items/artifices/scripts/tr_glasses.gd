extends Artifice

const size_x = 3;
const size_y = 3;

const rarity = 3;

func get_description()->String:
	return "In battle, throw at an ally or enemy unit to give them a small shield and send them walking randomly until the shield breaks."


func use()->bool:
	throw()
	return consume()

func hit_callback(hit_target:ActiveFighter)->void:
	var shield:float = hit_target.max_hp/10
	Combat.shield_target(Entities.player_fighter, hit_target, shield);
