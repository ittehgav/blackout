extends ColorRect;
@export var samples:Array[ItemSample]
signal looting_finished
@export var item_chosen_sfx:AudioStreamPlayer

func show_dungeon_loot(source:LootInventory)->void:
	get_parent().dungeon.cleared = true
	Tweens.ui_fade_in(self);
	var i:int = 0;
	var already_rolled:Array[Item]
	while i < 3:
		var loot_roll:Item = source.item_pool.pick_random();
		if loot_roll not in already_rolled:
			already_rolled.append(loot_roll);
			samples[i].load_item(loot_roll, 4);
			i += 1;

func item_chosen(item:Item)->void:
	var sheet_display:InventoryDisplay = Entities.player_sheet.player_inventory;
	sheet_display.open(); 
	## needs to have ran at least once for stuff to work?
	await get_tree().process_frame;
	if sheet_display.has_room(item):
		Entities.player.inventory.add_child(item)
		looting_finished.emit()
		item_chosen_sfx.play()
	else:
		Entities.player_sheet.request_space_for_item(item);
		await Entities.player_sheet.space_request_cleared;
		item_chosen_sfx.play()
		looting_finished.emit();


		
func _on_choice_1_pressed() -> void:
	item_chosen(samples[0].item)

func _on_choice_2_pressed() -> void:
	item_chosen(samples[1].item)

func _on_choice_3_pressed() -> void:
	item_chosen(samples[2].item)
