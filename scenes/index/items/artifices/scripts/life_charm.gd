extends Artifice

const size_x = 1;
const size_y = 1;

const rarity = 3;

func get_description()->String:
	return "While equipped, if you would die in battle, instead consume Life Charm and restore HP over time.";


func use()->bool:
	## TODO 
	return consume()
