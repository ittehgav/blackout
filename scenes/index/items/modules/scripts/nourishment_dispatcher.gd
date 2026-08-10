extends Module;

const rarity = 2;

func get_description()->String:
	return "Consumes " +Index.get_color_tag("food")+ str(ammo_cost)+ " food[/color] to give all units in party a"\
	+Index.get_color_tag("max_hp")+" regeneration buff.";
	

func use()->void:
	pass
	

const m1_description = "Consumes 50% less food."
const m1_prefix = "Frugal";

const m2_description = "Also consumes some juice and gives all allies an attack buff.";
const m2_prefix = "Spicy"
