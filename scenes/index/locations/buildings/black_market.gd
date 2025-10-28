extends Building

@export var rotating_inventory_1:ShopInventory;
@export var rotating_inventory_2:ShopInventory;
func refresh_stores()->void:
	rotating_inventory_1.refresh_inventory()
	rotating_inventory_2.refresh_inventory()
	
