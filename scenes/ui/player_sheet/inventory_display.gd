extends Panel

@export var discard_sfx:AudioStreamPlayer

@export var discard_overlay:Control
@export var inventory_display:InventoryDisplay;


@export var confirmation_overlay:ColorRect;
@export var confirmation_label:RichTextLabel

var to_discard:ItemMirror;

func _on_discard_item_pressed() -> void:
	Tweens.ui_fade_in(discard_overlay);
	inventory_display.choosing_item = true
	inventory_display.item_picked_up.connect(discard_confirmation, CONNECT_ONE_SHOT)

func discard_confirmation(mirror:ItemMirror)->void:
	to_discard = mirror;
	var item_color_tag:String = Index.get_color_tag(mirror.item.color_tag)
	confirmation_label.text = "Discard "+item_color_tag + mirror.item.name + "[/color] from your inventory?";
	
	await Tweens.ui_fade_in(confirmation_overlay).finished
	inventory_display.choosing_item = false;
	


func _on_confirm_discard_pressed() -> void:
	discard_sfx.play()
	inventory_display.remove_mirror(to_discard, true);
	revert_discard_overlay();
	


func _on_cancel_discard_pressed() -> void:
	revert_discard_overlay()

func revert_discard_overlay()->void:
	confirmation_overlay.hide();
	discard_overlay.hide()


func _on_player_sheet_closed() -> void:
	revert_discard_overlay();
