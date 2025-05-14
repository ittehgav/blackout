extends Settlement

class_name Farm

const settlement_type_name = "Farm"
const sub_name = "Farm"
var description:String = "Produces and trades " + Index.resource_colored_name("food") + \
"[/color] and some "+Index.resource_colored_name("fuel") +"[/color]."
var flavor:String = "Settlement formed around patches of fertile land.\nVery little of "+ Index.get_color_tag("blackout")\
+ "Pre-Blackout[/color] farming technology is properly understood, yet the demand for food remains ever-growing.";



func initiate_inventory()->void:
	var basket:ResourceContainer = Index.food_basket_scene.instantiate();
	inventory.add_child(basket)
	non_sellable_items.append(basket);
	
	var tank:ResourceContainer = Index.fuel_tank_scene.instantiate();
	inventory.add_child(tank)
	non_sellable_items.append(tank)
	
	var flask:ResourceContainer = Index.juice_flask_scene.instantiate();
	inventory.add_child(flask);
	non_sellable_items.append(flask);
	
	var crate:ResourceContainer = Index.scrap_crate_scene.instantiate();
	inventory.add_child(crate);
	non_sellable_items.append(crate);
	
	
