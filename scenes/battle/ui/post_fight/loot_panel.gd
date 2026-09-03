extends Panel
@export var enemy_team:Team

@export var player_inventory_display:InventoryDisplay;
@export var enemy_inventory_display:InventoryDisplay

@export var take_loot_btn:Button;
@export var continue_btn:Button

@export var looted_money_label:Label;
@export var player_resources:ResourcesDropdown




func set_reset_state()->void:
	player_inventory_display.set_reset_state()
	enemy_inventory_display.set_reset_state()

func display_loot(player_inventory:Inventory, loot_inventory:LootInventory)->void:
	Tweens.ui_fade_in(self)

	player_inventory_display.inventory = player_inventory
	player_inventory_display.open()
	
	enemy_inventory_display.inventory = loot_inventory;
	enemy_inventory_display.open();
	
	looted_money_label.text = str(loot_inventory.money)
	
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
	
func loot_money()->Tween:
	var player:Player = Entities.player
	var money_gain:int = int(looted_money_label.text);
	
	var tween:Tween = Tweens.tween_count_label(looted_money_label, 0);
	var player_money_label:Label = player_resources.resource_icons["money"].label
	
	Tweens.tween_count_label(player_money_label, player.inventory.money + money_gain);
	
	player.inventory.change_resource("money", money_gain)
	
	return tween;


func _on_sort_inventory_pressed() -> void:
	Entities.player.inventory.sort_items_by_size();
	player_inventory_display.hard_reset()
