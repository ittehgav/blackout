extends VBoxContainer
class_name ResourcesDropdown

@export var target_inventory:Inventory;


@export var resource_hboxes:Dictionary[String, HBoxContainer]
@export var resource_icons:Dictionary[String, ResourceIcon]
@export var from_player:bool

func _ready()->void:
	if get_parent() is InventoryDisplay: return;
	## gets and refreshed by inv display scripts
	## only other scenario is the one in the world map that refreshses along 
	## with player inventory (when it's in the tree)
	if from_player:
		var player:Player = Entities.player;
		target_inventory = player.inventory;
		player.resource_changed.connect(_on_player_resource_changed)
	if target_inventory:
		setup(target_inventory);
	
	
func setup(target:Inventory)->void:
	if update in target_inventory.changed.get_connections():
		## for shop stuff mostly
		target_inventory.changed.disconnect(update);

		
	target_inventory = target;
	for r:String in Resources.all_resources:
		resource_icons[r].source = target_inventory;
	target_inventory.changed.connect(update)

	update();

func update(concurring_inventories:Array[Inventory] = [], animated:bool=false)->void:
	## concurring inventories is so you can see your resources you have 0
	## of when trading with someone who has it
	if not animated:
		## TODO clear the race condition in a cleaner way?
		target_inventory.refresh_resource_counts()
		
		for r:String in Resources.all_resources:
			resource_icons[r].update();
			if r not in ["money", "food", "fuel"]:
				resource_hboxes[r].hide()
				if target_inventory[r]:
						resource_hboxes[r].show()
				for i:Inventory in concurring_inventories:
					if i[r]:
						resource_hboxes[r].show()
	else:
		for r:String in Resources.all_resources:
			var label:Label = resource_icons[r].label;
			var current_value:int = int(label.text);
			var target:int = target_inventory[r];
			
			var tween:Tween = create_tween();
			tween.tween_method(set_label_text.bind(label), current_value, target, .65)


func set_label_text(target:int, label:Label)->void:
	label.text = str(target)


func _on_player_resource_changed(_resource: String) -> void:
	update();
