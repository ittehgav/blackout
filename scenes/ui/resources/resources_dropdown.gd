extends VBoxContainer
class_name ResourcesDropdown

@export var target_inventory:Inventory;

@export var resource_labels:Dictionary[String, Label];
@export var resource_hboxes:Dictionary[String, HBoxContainer]
@export var resource_icons:Dictionary[String, ResourceIcon]



func refresh(concurring_inventories:Array[Inventory] = [])->void:
	for r:String in Index.all_resources:
		resource_labels[r].text = str(target_inventory[r])
		if r != "money":
			resource_hboxes[r].hide()
			if target_inventory[r]:
				resource_hboxes[r].show()
			for i:Inventory in concurring_inventories:
				if i[r]:
					resource_hboxes[r].show()
					
	
	
		
	


func _on_player_resource_changed(_resource: String, _change: int) -> void:
	refresh();
