extends Consumable


## TODO subclass for books?
## just a dictionary that goes to the player since there's not 
## much subjectivity to the books mechanic? 
const size_x = 2;
const size_y = 2;

const rarity = 3;

func get_description()->String:
	return "Use for the first time to permanently reduce your party's " + Resources.resource_colored_name("food") + " consumption by 25%.";
