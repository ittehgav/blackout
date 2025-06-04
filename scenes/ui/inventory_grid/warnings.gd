extends Control

@export var inventory_display:InventoryDisplay;

@export var liquid_discard_label:RichTextLabel;
@export var loot_discard_label:Label;
@onready var all_labels:Array[Control] = [liquid_discard_label, loot_discard_label];

func _ready()->void:
	liquid_discard_label.text = Index.resource_colored_name("fuel", true, true) + " and " + Index.resource_colored_name("juice", true, true)\
	 + " are [u]liquid[/u] and need to be stored in containers, otherwise they'll be discarded.";


func show_warnings()->void:
	var warnings:Dictionary = inventory_display.warnings;
	Tweens.ui_fade_in(self);
	for key:String in warnings.keys():
		var label:Control= self[key + "_label"];
		if warnings[key]:
			label.show();
		else:
			label.hide();
	


func _on_return_pressed() -> void:
	Tweens.ui_fade_out(self);
	inventory_display.warnings_attended.emit(false);


func _on_accept_pressed() -> void:
	if inventory_display.warnings.liquid_discard:
		for item_mirror:ItemMirror in inventory_display.liquid_item_mirrors:
			item_mirror.free();
	inventory_display.reset_warnings();
	Tweens.ui_fade_out(self);
	inventory_display.warnings_attended.emit(true);
	
	inventory_display.update_inventory();


func _on_auto_sort_pressed() -> void:
	inventory_display.store_all_resources();
	inventory_display.sort_inventory();
	Tweens.ui_fade_out(self);
	inventory_display.warnings_attended.emit(true);
	
	inventory_display.reset_warnings();
	inventory_display.update_inventory();
	
