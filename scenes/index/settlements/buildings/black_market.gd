extends Building




@export var opt_1_arg:ShopInventory;
@export var opt_2_arg:ShopInventory;
@export var opt_3_arg:ShopInventory;



func refresh_stores()->void:
	opt_1_arg.refresh_inventory()
	opt_2_arg.refresh_inventory()
	opt_3_arg.refresh_inventory()
