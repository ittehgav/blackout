extends Panel

@export var player_inventory_display:InventoryDisplay;
@export var loot_display:InventoryDisplay;

func setup()->void:
	player_inventory_display.inventory = Entities.player.inventory;
	player_inventory_display.set_grid();
	player_inventory_display.refresh_data(true);
	
	var loot:Inventory = Entities.arena.battle_loot;
	loot_display.inventory = loot;
	loot_display.set_grid();
	loot_display.refresh_data(true);


func _on_loot_all_btn_pressed() -> void:
	for item in loot_display.item_mirrors_node.get_children():
		item.loot_command();
