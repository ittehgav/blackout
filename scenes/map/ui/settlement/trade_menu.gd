extends Control

@export var player_inventory_display:InventoryDisplay;
@export var trader_inventory_display:InventoryDisplay;

func start_trade(target:MapEntity)->void:
	player_inventory_display.current_inventory = Entities.player.inventory;
	player_inventory_display.set_grid()
	player_inventory_display.refresh_data();
	
	target.inventory.sort_items();
	trader_inventory_display.current_inventory = target.inventory;
	trader_inventory_display.set_grid();
	trader_inventory_display.refresh_data();
