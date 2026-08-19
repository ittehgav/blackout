extends Control

@export var discard_sfx:AudioStreamPlayer;

@export var inventory_display:InventoryDisplay;

@export var confirmation_overlay:ColorRect;
@export var confirmation_label:RichTextLabel;

@export var discard_btn:Button;
@export var cancel_discard_btn:Button

var current_discard_target:ItemMirror

func _on_discard_item_pressed()->void:
	Tweens.ui_fade_in(self);
	inventory_display.choosing_item = true;
	inventory_display.item_picked_up.connect(discard_confirmation, CONNECT_ONE_SHOT);
	
	discard_btn.hide();
	cancel_discard_btn.show()
	
func discard_confirmation(mirror:ItemMirror)->void:
	if mirror.item in Entities.player.bound_items:
		inventory_display.invalid_move.emit("CAN'T DISCARD");
		revert_discard_overlay()
		return
	current_discard_target = mirror;
	var tag:String = Index.get_color_tag(mirror.item.color_tag)
	confirmation_label.text = "Discard " + tag + mirror.item.unique_name + "[/color] from your inventory?";
	
	await Tweens.ui_fade_in(confirmation_overlay).finished;
	inventory_display.choosing_item = false;
	Entities.player_sheet.item_discarded.emit()

	
func _on_confirm_discard_pressed()->void:
	discard_sfx.play();
	inventory_display.remove_mirror(current_discard_target, true);
	revert_discard_overlay();
	

func _on_cancel_discard_pressed()->void:
	revert_discard_overlay();

func revert_discard_overlay()->void:
	confirmation_overlay.hide();
	hide()
	
	discard_btn.show();
	cancel_discard_btn.hide()
