extends Panel
@export var enemy_team:Team

@export var player_inventory_display:InventoryDisplay;
@export var enemy_inventory_display:InventoryDisplay

@export var take_loot_btn:Button;

var initial_player_inventory:Inventory;
var initial_enemy_inventory:Inventory;




func set_reset_state()->void:
	initial_player_inventory = player_inventory_display.set_reset_state()
	initial_enemy_inventory = enemy_inventory_display.set_reset_state()

func display_loot()->void:
	Tweens.ui_fade_in(self)
	var loot_inventory:LootInventory = enemy_team.roster.loot;

	player_inventory_display.inventory = Entities.player.inventory;
	player_inventory_display.opened.emit()
	enemy_inventory_display.inventory = loot_inventory;
	enemy_inventory_display.opened.emit();
	
	player_inventory_display.refresh_data();
	enemy_inventory_display.refresh_data();
	
	set_reset_state()

func _on_take_loot_pressed() -> void:
	enemy_inventory_display.all_mirrors[0].loot_command()
	check_available_loot()

func check_available_loot(_mirror:ItemMirror=null, _arg:Variant = null)->void:
	if len(enemy_inventory_display.all_mirrors) == 0:
		take_loot_btn.disabled = true
