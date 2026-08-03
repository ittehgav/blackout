extends Artifice

const size_x = 2;
const size_y = 1;

const rarity = 2;



func get_description()->String:
	return "In battle, throw Lure at an enemy to have a swarm of insets attack them."


func use()->bool:
	throw()
	return consume()

func hit_callback(target:ActiveFighter)->void:
	
	pass
