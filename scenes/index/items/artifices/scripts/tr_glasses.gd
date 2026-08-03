extends Artifice

const size_x = 3;
const size_y = 3;

const rarity = 3;

func get_description()->String:
	return "In battle, use on a unit to give them a small shield and send them walking randomly until the shield breaks."


func use()->bool:
	return consume()
