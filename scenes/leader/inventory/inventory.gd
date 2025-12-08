extends Node2D

## any settlement or party has an inventory
class_name Inventory;

signal changed;


@export var expandable:bool=false
## right now just for shop inventories to have infinite space

@export var holder:Node;

@export_subgroup("Resource Counters")
## resource counters and resource items remain consistant with eachother
## and can both be used for checking and updating eachother
@export var food:int;
@export var money:int;
@export var fuel:int;

@export var juice:int;
@export var scrap:int;
@export var chips:int;

@export_subgroup("Items")
@export var items:Array[Item];

@export var containers:Array[ResourceContainer];
@export var consumables:Array[Consumable];
@export var accessories:Array[Accessory];

@export_subgroup("Equipment")
@export var weapons:Array[Weapon];
@export var modules:Array[Module];

@export var capacity_x:int = 8;
@export var capacity_y:int = 12;

func _ready()->void:
	await get_parent().ready
	refresh_resource_counts();

func refresh_resource_counts(_resource:String="")->void:
	var previous_amounts: = {}
	for r:String in Index.all_resources:
		previous_amounts[r] = self[r];
		if r != "money":
			self[r] = 0;
	for c in containers:
		self[c.resource] += c.stack_size;



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
							add_item(raw_stack)
				i += 1
	else:
		money += amount
	refresh_resource_counts();
	if holder is Player:
		## call deferred so the values are updated beofre the animation plays
		Entities.player.resource_changed.emit.call_deferred(resource);



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
	if emit_change:
		changed.emit()

func send_item(item:Item, target:Inventory)->void:
	remove_item(item);
	target.add_item(item);

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
	for r:String in Index.all_resources:
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
				add_item(raw_stack);


func sort_items()->void:
	## only ever run if guaranteed that everything will fit
	
	## backup if sort gets an infinite loop
	var original_positions:Dictionary[Item, Vector2];
	store_resources()
	
	for item in items:
		original_positions[item] = item.inventory_position;
		item.inventory_position = Vector2(-1, -1)

	var taken_cells:Array[Vector2];
	var reset:bool = false;
	for item in items:
		if item not in Entities.player.equipment:
			var fit:bool = throw_item(item, taken_cells);
			if not fit:
				reset = true
				break;
	if reset:
		for item in items:
			item.inventory_position = original_positions[item];


func size_sort(a:Item, b:Item)->bool:
	return a.size_x * a.size_y > b.size_x * b.size_y;


func throw_item(item:Item, taken_cells:Array[Vector2])->bool:
	## every non-player inventory is top-right oriented instead of top-left
	## ONLY ITEMS THAT FIT CAN MAKE IT HERE
	var spot:Vector2;
	if self == Entities.player.inventory:
		spot = Vector2.ZERO;
	else:
		spot = Vector2(capacity_x - 1, 0);
	while not fits_in_spot(item, spot, taken_cells):
		if self == Entities.player.inventory:
			spot.x += 1;
			if spot.x == capacity_x:
				spot.x = 0;
				spot.y  += 1;
		else:
			spot.x -= 1;
			if spot.x == - 1:
				spot.x = capacity_x - 1;
				spot.y += 1;
		if spot.y == capacity_y + 1:
			return false;

	item.inventory_position = spot;
	for x:int in item.size_x:
		for y:int in item.size_y:
			taken_cells.append(Vector2(x + spot.x, y + spot.y))
	return true
	
	
func fits_in_spot(item:Item, spot:Vector2, taken_cells:Array[Vector2])->bool:
	for x:int in item.size_x:
		for y:int in item.size_y:
			var to_check:Vector2 = Vector2(x + spot.x, y + spot.y);
			if not cell_in_grid(to_check) or to_check in taken_cells:
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
		if node in [
			holder.equipped_weapon,
			holder.alternative_weapon,
			holder.equipped_module,
			holder.equipped_accessory_1,
			holder.equipped_accessory_2
		]:
			holder.equipment.append(node)
	
	if not items.has(node):
		## ONLY EVER FROM INVENTORIES THAT WERE MADE IN-EDITOR
		add_item(node);
	remove_child.call_deferred(node);

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
