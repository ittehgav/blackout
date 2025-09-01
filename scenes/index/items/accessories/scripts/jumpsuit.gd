extends Accessory

const size_x = 2; ## TEXTURE MISMATCHING
const size_y = 2;

const rarity = 2;


func get_description()->String:
	var description:String = super();
	description += "Increases the wearer's " + Index.stat_colored_name("defense") + " and " + Index.stat_colored_name("technique") + ".";
	return description;
