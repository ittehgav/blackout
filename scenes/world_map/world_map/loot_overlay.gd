extends TextureRect

@export var dungeon_prompt:Control

var dungeon:Dungeon
@export var item_option_panel:PanelContainer;
@export var options_hbox:HBoxContainer

@export var loot_chosen_sfx:AudioStreamPlayer;

func display_loot(target:Dungeon)->void:
	show()
	for c:Node in options_hbox.get_children():
		c.queue_free();
	
	dungeon = target;
	var loot:Array[Item] = dungeon.roll_loot()
	for item:Item in loot:
		var option:PanelContainer = item_option_panel.duplicate();
		option.load_item(item);
		option.choose_btn.pressed.connect(loot_chosen.bind(item))

		options_hbox.add_child(option);

func loot_chosen(item:Item)->void:
	## try to send to player's inventory, if there's no room, open
	## player sheet with message/overlaying item png asking for space
	var display:InventoryDisplay = Entities.player_sheet.inventory_view.inventory_display
	var spot:Vector2i = display.find_clear_cell(item)
	if spot != Vector2i(-1, -1):
		Entities.player.inventory.add_item(item, true);
		item.inventory_position = spot;
		display.mirror_item(item);
		loot_chosen_sfx.play()
		loot_finished()
	else:
		Entities.player_sheet.request_space_for_item(item)
		Entities.player_sheet.closed.connect(loot_finished)
		
func loot_finished()->void:
	hide();
	dungeon_prompt.dungeon_cleared_animation()
