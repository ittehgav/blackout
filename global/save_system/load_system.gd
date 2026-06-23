extends Node

## may cause problems if i ever end up having items 
## of different classes with the exact same name?
var scene_cache:Dictionary[String, PackedScene];

func load_inventory(inventory:Inventory, data:Dictionary)->void:
	## loads the data INTO AN EXISTING INVENTORY INSTANCE
	inventory.money = data.money
	
	for container_data:Dictionary in data.containers:
		var item:ResourceContainer = load_item(container_data, "container")
		inventory.add_item(item);
	
	inventory.refresh_resource_counts()
	
	for weapon_data:Dictionary in data.weapons:
		inventory.add_item(load_item(weapon_data, "weapon"));
	
	for module_data:Dictionary in data.modules:
		inventory.add_item(load_item(module_data, "module"));
	
func load_item(data:Dictionary, item_type:String)->Item:
	## GENERATES A NEW ITEM INSTANCE and returns it
	
	if not (data.filename in scene_cache):
		scene_cache[data.filename] = load("res://scenes/indexes/items/" + item_type+"s/" + data.filename+".tscn");
	var item:Item = scene_cache[data.filename].instantiate()
	
	item.inventory_position = load_vector2(data.inventory_position);
	
	if item is ResourceContainer:
		item.stack_size = data.stack_size;

	return item
	
func load_roster(roster:Roster, data:Array)->void:
	## LOADS DATA INTO EXISTING ROSTER INSTANCE
	## leaving it ready and operation
	for unit_data:Dictionary in data:
		roster.add_unit(load_fighter_unit(unit_data))

func load_fighter_unit(data:Dictionary)->FighterUnit:
	var unit:FighterUnit = Index.scenes.fighter_unit.instantiate();
	var fighter_base:FighterBase = Index.fighters.find_base(data.base_name);
	
	unit.base = fighter_base
	unit.level = data.level;
	unit.experience = data.exp;
	
	## bases don't have to be in the tree to do all that they do right now
	## they never get referenced from the children of the fighter

	
	for stat:String in CombatStats.all_stats:
		unit.modifier_stats[stat] = data.modifier_stats[stat];
	
	unit.update_stats();
	return unit

func load_vector2(data:String)->Vector2:
	var x:int = int(data.split(",")[0].split("(")[1]);
	var y:int = int(data.split(",")[1].split(")")[0]);
	
	return Vector2(x, y);
	
	
	
	
	
