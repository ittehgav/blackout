extends ShopInventory

@export var accessory_pool:Array[Item]
@export var consumable_pool:Array[Item]
@export var module_pool:Array[Item]
@export var weapon_pool:Array[Item]

var current_item_type:String

func refresh_inventory()->void:
	current_item_type = ["accessory", "consumable", "module", "weapon"].pick_random()
	name = current_item_type.capitalize() + " Smuggler"
	var pool:Array[Item] = self[current_item_type+"_pool"]
	item_pool.clear();
	for item:Item in pool:
		item_pool.append(item.duplicate());
		
	super()

func _on_child_entered_tree(node: Node) -> void:
	assert(node is Item);
	if node in accessory_pool\
	or node in consumable_pool\
	or node in module_pool\
	or node in weapon_pool:
		remove_child.call_deferred(node);
	else:
		super(node)
