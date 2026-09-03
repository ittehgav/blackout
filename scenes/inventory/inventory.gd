@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_bag.png")
extends Node2D

## any settlement or party has an inventory
class_name Inventory;

signal changed;


@export var holder:Node;


## resource counters and resource items remain consistant with eachother
## and can both be used for checking and updating eachother
@export var money:int;

var food:int:
	get():
		return get_resource_count("food")
var fuel:int:
	get():
		return get_resource_count("fuel")
var juice:int:
	get():
		return get_resource_count("juice")
var scrap:int:
	get():
		return get_resource_count("scrap")
var chips:int:
	get():
		return get_resource_count("chips")

func get_resource_count(r:String)->int:
	var count:int = 0;
	for c:ResourceContainer in containers:
		if c.resource == r:
			count += c.stack_size;
	return count;


@export_subgroup("Items")
@export var items:Array[Item];

@export var containers:Array[ResourceContainer];
@export var consumables:Array[Consumable];
@export var accessories:Array[Accessory];


@export_subgroup("Equipment")
@export var weapons:Array[Weapon];
@export var modules:Array[Module];
@export var artifices:Array[Artifice]
@export var car_keys:Array[CarKey]

@export_subgroup("Capacity")
@export var capacity_x:int = 0;
@export var capacity_y:int = 12;
## player inventory  will always have Big Family as a starter

var last_display:InventoryDisplay;
## to keep track of shops/refinement menus that were opened before the player sheet


func change_resource(resource:String, amount:int)->void:
	## only runs if the inventory has enough resources to remove
	assert(self[resource] >= amount * -1)
	if resource != 'money':
		var containers_with_resource:Array[ResourceContainer];
		for c:ResourceContainer in containers:
			if c.resource == resource:
				containers_with_resource.append(c)
				
		containers_with_resource.sort_custom(containers[0].capacity_sort);
		
		var i:int = 0;
		if amount < 0:
			var to_remove:int = -amount
			while to_remove:
				var c:ResourceContainer = containers_with_resource[i];
				if c.stack_size >= to_remove:
					c.stack_size -= to_remove;
					to_remove = 0;
					if c.check_empty():
						remove_item(c)
				else:
					to_remove -= c.stack_size;
					c.stack_size = 0;
					if c.check_empty():
						remove_item(c)
				i += 1;
		else:
			var to_add:int = amount;
			while to_add:
				if i < len(containers_with_resource):
					var c:ResourceContainer = containers_with_resource[i];
					if c.space_left() >= to_add:
						c.stack_size += to_add;
						to_add = 0;
					else:
						to_add -= c.space_left()
						c.stack_size += c.space_left();
				else:
					var raw_stack:ResourceContainer = Index.scenes.items[resource + "_stack"].instantiate();
					if raw_stack.mirror_only:
						## somehow signal that resources went to waste?
						to_add = 0;
					else:
						if raw_stack.capacity >= to_add:
							raw_stack.stack_size = to_add;
							to_add = 0;
						else:
							## sometimes there won't be enough room?
							raw_stack.stack_size = raw_stack.capacity;
							to_add -= raw_stack.capacity;
							add_child(raw_stack)
				i += 1
	else:
		money += amount
	if holder is Player:
		## call deferred so the values are updated beofre the animation plays
		Entities.player.resource_changed.emit.call_deferred(resource);
	
	changed.emit()


func add_item(item: Item, emit_change:bool=false) -> void:
	assert(not items.has(item))
	## INVENTORIES AND ROSTERS JUST NEED TO HAVE THE UNITS AS CHILDREN TO PROPERLY CATEGORIZE THEM
	items.append(item);
	if item is Consumable:
		consumables.append(item);
	elif item is Accessory:
		accessories.append(item);
	elif item is Module:
		modules.append(item);
	elif item is Weapon:
		weapons.append(item);
	elif item is ResourceContainer:
		## default containers from travelling traders will be manually added to the containers array 
		## so the resources can be restored before entering the tree
		containers.append(item)
	elif item is Artifice:
		artifices.append(item)
	elif item is CarKey:
		car_keys.append(item)
		capacity_x += item.cargo_space/12
		## only messing with x_size to keep it simple rn
		
	if emit_change:
		changed.emit()

func send_item(item:Item, target:Inventory)->bool:
	remove_item(item);
	if item is ResourceContainer and item.raw_stack:
		for c:ResourceContainer in target.containers:
			if c.resource == item.resource:
				var space_left:int = c.space_left();
				if space_left >= item.stack_size:
					c.stack_size += item.stack_size;
					return false;
				else:
					c.stack_size = c.capacity;
					item.stack_size -= space_left;
	item.reparent(target)
	return true

func remove_item(item:Item)->void:
	## items are only ever removed by de-referencing
	assert(item in items);
	
	items.erase(item);
	if item is Consumable:
		consumables.erase(item);
	elif item is Accessory:
		accessories.erase(item);
	elif item is Module:
		modules.erase(item);
	elif item is Weapon:
		weapons.erase(item);
	elif item is ResourceContainer:
		containers.erase(item)
	elif item is Artifice:
		artifices.erase(item)
	elif item is CarKey:
		car_keys.erase(item);
		capacity_x -= item.cargo_space/12
	remove_child.call_deferred(item)
	changed.emit()


func clear_containers()->void:
	var to_remove:Array[ResourceContainer]
	for c:ResourceContainer in containers:
		if c.raw_stack:
			## cam't just queue fere because it needs to be 
			## out of the items array in the same frame
			to_remove.append(c)
		else:
			c.stack_size = 0;
			
	for c:ResourceContainer in to_remove:
		## CANT ITERATE OVER AN ARRAY WHILE MOVING/DELETINGS ITS ELEMENTS XDD
		remove_item(c);
	
func store_resources()->void:
	## applied after changing resource counters
	## used after resources are gained from whatever source , allocates 
	## unallocated resources to the containers with the highest capacity
	clear_containers();
	for r:String in Resources.all_resources:
		if r != "money":
			var to_store:int = self[r];
			
			var containers_with_resource:Array[ResourceContainer]=\
			containers.filter(func(a:ResourceContainer)->bool:return a.resource == r);
			containers_with_resource.sort_custom(sort_containers);
			for c:ResourceContainer in containers_with_resource:	
				if to_store:
					if c.capacity >= to_store:
						c.stack_size += to_store;
						to_store = 0;
						
					else:
						c.stack_size = c.capacity;
						to_store -= c.capacity;
			while to_store:
				var raw_stack:ResourceContainer = Index.scenes.items[r+"_stack"].instantiate()
				if raw_stack.mirror_only or raw_stack.capacity >= to_store:
					raw_stack.stack_size = to_store;
					to_store = 0;
				else:
					raw_stack.stack_size = raw_stack.capacity;
					to_store -= raw_stack.capacity;
				add_child(raw_stack);


func has_room(item:Item)->bool:
	for x:int in capacity_x:
		for y:int in capacity_y:
			var spot:Vector2i = Vector2i(x, y);
			if fits_in_spot(item, spot):
				return true;
	return false

func fits_in_spot(item:Item, spot:Vector2)->bool:
	for x:int in item.size_x:
		for y:int in item.size_y:
			var to_check:Vector2 = Vector2(x + spot.x, y + spot.y);
			if not cell_in_grid(to_check):
				return false;
			
	return true

func cell_in_grid(cell:Vector2)->bool:
	if cell.x < 0 or cell.x >= capacity_x:
		return false;
	if cell.y < 0 or cell.y >= capacity_y:
		return false;
	return true;


func _on_child_entered_tree(node: Node) -> void:
	assert(node is Item);
	## so editor-made nodes work and are easy to edit
	
	if holder is Player:
		## will need to do something similar for npc leaders and equipment?
		## NPCs just have infinite inventory space that shrinks to fit their items however?
		var equipped_artifices:Array[Artifice] = holder.equipped_artifices.values()
		var equipped_slots:Array[Item] =  [
				holder.equipped_weapon,
				holder.alternative_weapon,
				holder.equipped_module,
				holder.equipped_accessory_1,
				holder.equipped_accessory_2,
			]
		equipped_slots.append_array(equipped_artifices)
		if node in equipped_slots or node in holder.roster.equipped_accessories:
			holder.equipment.append(node)
	
	
	if not items.has(node):
		add_item(node);

func sort_containers(a:ResourceContainer, b:ResourceContainer)->bool:
	if a.capacity > b.capacity:
		return true
	elif b.capacity > a.capacity:
		return false;
	else:
		return a.stack_size > b.stack_size;



func empty_inventory()->void:
	## simply unindexes all items
	## currently for them to be replaced by the original items
	## when resetting the trade
	
	## idk the all arrays thing was not working for shop inventories
	weapons.clear()
	modules.clear()
	consumables.clear()
	accessories.clear()
	containers.clear()
	
	items.clear()
	

func taken_space()->int:
	var space:int = 0;
	for item:Item in items:
		if not (item is Equipment) or (not item in Entities.player.equipment\
			and not item in Entities.player.roster.equipped_accessories):
			space += item.size_x * item.size_y;
	assert(space <= capacity_x * capacity_y)
	return space

func sort_items_by_size()->void:
	items.sort_custom(size_sort);
	for i in items:
		i.inventory_position = InventoryDisplay.ITEM_UNPLACED

func size_sort(i1:Item, i2:Item)->bool:
	return i1.size_x * i2.size_y > i2.size_x * i2.size_y;

func get_item_count(item:Item)->int:

	## right now this would never show an error over something 
	## correctly placed but not really a rule that needs to be?
	var total:int=0
	for i:Item in items:
		if i.unique_name == item.unique_name:
			total += 1;
	
	return total;
