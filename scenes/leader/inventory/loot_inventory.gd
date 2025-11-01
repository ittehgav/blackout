extends Inventory

class_name LootInventory

@export var item_pool:Array[Item];

## minimum amt of rare items
@export var rare_count:int=0;

func _on_child_entered_tree(node: Node) -> void:
	## items added as children of LootInventory will be part of the pool
	## items added as children of LootInventory will be part of the pool
	assert(node is Item);
	item_pool.append(node);
	remove_child.call_deferred(node)

func generate_loot(party_level:int)->void:
	assert(len(item_pool))
	money = randi_range(party_level/2, party_level * 1.5)
	## loot formula = generates a total sum of item value based on the level of the roster
	var target_value_sum:int = party_level/2;
	var current_sum:int = 0;
	while current_sum < target_value_sum:
		var new_item:Item = generate_item(current_rare_count() < rare_count);
		current_sum += new_item.get_price()

func generate_item(force_rare:bool=false)->Item:
	var new_item:Item;
	if force_rare:
		new_item = item_pool.filter(func(item:Item)->bool:return item.rarity == 3).pick_random()
	else:
		new_item = item_pool.pick_random().duplicate(DUPLICATE_USE_INSTANTIATION);
	add_item(new_item);
	return new_item

func current_rare_count()->int:
	return len(items.filter(func(item:Item)->bool:return item.rarity == 3));
