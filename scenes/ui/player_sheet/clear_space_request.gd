extends PanelContainer

@export var sample:ItemSample
@export var request_label:RichTextLabel;

@export var inventory_display:InventoryDisplay

@export var projection_sample:ItemSample;

var pending_item:Item

func request_space_for_item(item:Item)->void:
	show();
	Entities.player_sheet.item_discarded.connect(check_clear_space)
	pending_item = item
	var color_tag:String = Index.get_color_tag(item.color_tag)
	request_label.text = "Not enough space in inventory for "+color_tag + item.unique_name
	sample.load_item(item, 3);
	inventory_display.item_dropped.connect(check_clear_space)
	setup_projection()


func check_clear_space(_mirror:ItemMirror)->void:
	if inventory_display.has_room(pending_item):
		var to_add:Item = pending_item.duplicate(DUPLICATE_USE_INSTANTIATION)
		to_add.inventory_position = inventory_display.find_clear_cell(to_add);
		Entities.player.inventory.add_child(to_add, true)
		inventory_display.mirror_item(to_add)
		inventory_display.refresh_data()
		Entities.player_sheet.space_request_cleared.emit()
		
		clear_request();
	
func clear_request()->void:
	inventory_display.item_dropped.disconnect(check_clear_space)
	Entities.player_sheet.item_discarded.disconnect(check_clear_space)
	projection_sample.hide()
	await Tweens.ui_fade_out(self).finished;
	modulate.a = 1
	Entities.player_sheet.hide_player_sheet()
	Entities.player_sheet.space_request_cleared.emit()

func setup_projection()->void:
	projection_sample.show()
	projection_sample.load_item(pending_item, 3)
	projection_sample.position = Vector2(386, 578);
	projection_sample.modulate.a = .5
	projection_sample.position -= Vector2(48 * pending_item.size_x, 48 * pending_item.size_y)
	
