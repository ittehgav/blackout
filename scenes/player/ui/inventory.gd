extends Control

@export var inventory_panel:Panel;
@export var inventory_display:InventoryDisplay;


func _on_store_resources_pressed() -> void:
	inventory_display.store_all_resources();


func _on_sort_inventory_pressed() -> void:
	inventory_display.sort_inventory();
