extends Panel
@export var enemy_team:Team

@export var player_inventory_display:InventoryDisplay;
@export var enemy_inventory_display:InventoryDisplay

@export var take_loot_btn:Button;
@export var continue_btn:Button






func set_reset_state()->void:
	player_inventory_display.set_reset_state()
	enemy_inventory_display.set_reset_state()

func display_loot(player_inventory:Inventory, loot_inventory:LootInventory)->void:
	Tweens.ui_fade_in(self)

	player_inventory_display.inventory = player_inventory
	player_inventory_display.open()
	enemy_inventory_display.inventory = loot_inventory;
	enemy_inventory_display.open();
	
	player_inventory_display.refresh_data();
	enemy_inventory_display.refresh_data();
	
	set_reset_state()

func _on_take_loot_pressed() -> void:
	enemy_inventory_display.all_mirrors[0].loot_command()
	check_available_loot()

func check_available_loot(_mirror:ItemMirror=null, _arg:Variant = null)->void:
	if len(enemy_inventory_display.all_mirrors) == 0:
		take_loot_btn.disabled = true
		continue_btn.modulate.v = 1;
	else:
		take_loot_btn.disabled = false;
		continue_btn.modulate.v = .5
