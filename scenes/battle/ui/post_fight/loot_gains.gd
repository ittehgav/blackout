extends Panel

@export var post_fight:Control;

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
	for item:ItemMirror in loot_display.item_mirrors_node.get_children():
		item.loot_command();



func _on_continue_pressed() -> void:
	if player_inventory_display.pending_warnings():
		player_inventory_display.warn_player();
		var clear:bool = await player_inventory_display.warnings_attended;
		if clear:
			## warnings ignored = items discarded and clear to exit post_fight
			finish_looting();
			## otherwise it just goes back to the inventory displays until the players tries to exit again
	else:
		finish_looting();
	
func finish_looting()->void:
	player_inventory_display.update_inventory();
	post_fight.end_post_fight();
