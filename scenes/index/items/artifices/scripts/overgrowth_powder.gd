extends Artifice

const size_x = 1;
const size_y = 2;

const rarity = 2;

func get_description()->String:
	return "In battle, throw seeds that place thorns on an area that damage enemies and reduces their agility.";


func use()->bool:
	throw()
	return consume()

func detonate_callback(_hit_location:Vector2)->void:
	detonate_sfx.play()
