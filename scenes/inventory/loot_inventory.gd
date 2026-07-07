extends Inventory

class_name LootInventory

@export var item_pool:Array[Item];

## minimum amt of rare items
@export var rare_count:int=0;
var pool_generated:bool=false;

func _ready()->void:
	super();
	pool_generated = true;
	

func _on_child_entered_tree(node: Node) -> void:
	## items added as children of LootInventory will be part of the pool
	assert(node is Item);
	if not pool_generated:
		item_pool.append(node);
		remove_child.call_deferred(node)
	else:
		super(node)

func generate_loot(party_level:int)->void:
	if not len(item_pool):return
	## not all npcrosters will have loot but this is 
	## still worth the simpler nodes?
	money = randi_range(party_level, party_level * 2)
	## loot formula = generates a total sum of item value based on the level of the roster
	var target_value_sum:int = party_level/2;
	var current_sum:int = 0;
	while current_sum < target_value_sum:
		var new_item:Item = generate_item(current_rare_count() < rare_count);
		current_sum += new_item.get_price()
		if new_item is ResourceContainer:
			new_item.stack_size = randi_range(1, int(new_item.capacity/2))

func generate_item(force_rare:bool=false)->Item:
	var new_item:Item;
	if force_rare:
		new_item = item_pool.filter(func(item:Item)->bool:return item.rarity == 3).pick_random().duplicate(DUPLICATE_USE_INSTANTIATION)
	else:
		new_item = item_pool.pick_random().duplicate(DUPLICATE_USE_INSTANTIATION);
	assert(new_item)
	add_child(new_item);
	return new_item

func current_rare_count()->int:
	return len(items.filter(func(item:Item)->bool:return item.rarity == 3));
