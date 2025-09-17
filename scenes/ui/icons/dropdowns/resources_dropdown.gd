extends VBoxContainer
class_name ResourcesDropdown

@export var target_inventory:Inventory;

@export var resource_hboxes:Dictionary[String, HBoxContainer]
@export var resource_icons:Dictionary[String, ResourceIcon]


func _ready()->void:
	if target_inventory:
		setup();
	
func setup()->void:
	for r:String in Index.all_resources:
		resource_icons[r].source = target_inventory;
		

		

	update();

func update(concurring_inventories:Array[Inventory] = [])->void:
	## concurring inventories is so you can see your resources you have 0
	## of when trading with someone who has it
	for r:String in Index.all_resources:
		resource_icons[r].update();
		if r not in ["money", "food", "fuel"]:
			resource_hboxes[r].hide()
			if target_inventory[r]:
				resource_hboxes[r].show()
			for i:Inventory in concurring_inventories:
				if i[r]:
					resource_hboxes[r].show()


func _on_player_resource_changed(_resource: String, _change: int) -> void:
	update();
