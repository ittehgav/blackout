extends Settlement;

class_name Scrapyard

const settlement_type_name = "Scrapyard";
const sub_name = "Scrapyard"
var description:String = "Produces and trades mostly "\
+ Index.resource_colored_name("scrap") + "[/color] and"+Index.resource_colored_name("fuel") + " .[/color]"

var flavor:String = "Massive lots of crushed cars, a common landmark from "+Index.get_color_tag("blackout")\
 + "Pre-Blackout Civilization[/color], which get recycled and traded.";


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
