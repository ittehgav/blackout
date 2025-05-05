extends Settlement

class_name Factory

const settlement_type_name = "Factory"
const sub_name = "Factory"
var description: String = "Produces and trades mostly" + Index.resource_colored_name("fuel") + " [/color],"\
+ Index.resource_colored_name("juice") + " [/color] and"+Index.resource_colored_name("scrap") + " .[/color]";
var flavor:String = "Region full of manufacturing machinery from "+Index.get_color_tag("blackout") + "Pre-Blackout Civilization[/color], repurposed for production of mechanical and chemical goods.";


func initiate_inventory()->void:
	var bag:ResourceContainer = Index.food_bag_scene.instantiate();
	inventory.add_child(bag)
	non_sellable_items.append(bag);
	
	var barrel:ResourceContainer = Index.fuel_barrel_scene.instantiate();
	inventory.add_child(barrel)
	non_sellable_items.append(barrel)
	
	var tank:ResourceContainer = Index.juice_tank_scene.instantiate();
	inventory.add_child(tank);
	non_sellable_items.append(tank);
	
	var compactor:ResourceContainer = Index.scrap_compactor_scene.instantiate();
	inventory.add_child(compactor);
	non_sellable_items.append(compactor);
	
	var case:ResourceContainer = Index.chips_case_scene.instantiate();
	inventory.add_child(case);
	non_sellable_items.append(case);
