extends PanelContainer

@export var post_fight:Control;
@export var loot_sfx:AudioStreamPlayer;

@export var player_inventory_display:InventoryDisplay;
@export var loot_display:InventoryDisplay;

@export var money_gain_label:Label
@export var money_sfx:AudioStreamPlayer;

func setup()->void:
	player_inventory_display.inventory = Entities.player.inventory;
	player_inventory_display.set_grid();
	player_inventory_display.refresh_data(true);
	
	var loot:Inventory = Entities.arena.battle_loot;
	loot_display.inventory = loot;
	loot_display.set_grid();
	loot_display.refresh_data(true);
	
	money_gain_label.text = "+ " + str(Entities.arena.battle_money_loot);


func _on_loot_all_btn_pressed() -> void:
	for item:ItemMirror in loot_display.item_mirrors_node.get_children():
		item.loot_command();


func change_player_money_label(target:int)->void:
	player_inventory_display.money_label.text = str(target);
	
func animate_money_gain()->void:
	money_sfx.play();
	var font_size:int = player_inventory_display.money_label.get_theme_font_size("font_size");
	player_inventory_display.money_label.add_theme_font_size_override("font_size", font_size * 1.5 )
	var tween:Tween = create_tween();
	tween.tween_method(change_player_money_label, Entities.player.inventory.money, Entities.player.inventory.money + Entities.arena.battle_money_loot, 1);
	tween.tween_property(player_inventory_display.money_label, "theme_override_font_sizes/font_size", font_size, .1);
	Entities.player.inventory.change_resource("money", Entities.arena.battle_money_loot)

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
	## WAIT UNTIL ITEM NODES MOVE INVENTORIES BEFORE RETURNING TO WORLDMAPOL
	await Tweens.ui_fade_out(Entities.arena).finished;
	post_fight.end_post_fight();
