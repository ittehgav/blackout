extends VBoxContainer
class_name ResourcesDropdown

@export var target_inventory:Inventory;

@export var resource_hboxes:Dictionary[String, HBoxContainer]
@export var resource_icons:Dictionary[String, ResourceIcon]
@export var from_player:bool

func _ready()->void:
	if from_player:
		
		print("isfp?")
		target_inventory = Entities.player.inventory;
		Entities.player.resource_changed.connect(_on_player_resource_changed)
	if target_inventory:
		setup();
	
	
func setup()->void:
	for r:String in Index.all_resources:
		resource_icons[r].source = target_inventory;


	update();

func update(concurring_inventories:Array[Inventory] = [], animated:bool=false)->void:
	## concurring inventories is so you can see your resources you have 0
	## of when trading with someone who has it
	if not animated:
		for r:String in Index.all_resources:
			resource_icons[r].update();
			if r not in ["money", "food", "fuel"]:
				resource_hboxes[r].hide()
				if target_inventory[r]:
					resource_hboxes[r].show()
				for i:Inventory in concurring_inventories:
					if i[r]:
						resource_hboxes[r].show()
	else:
		for r:String in Index.all_resources:
			var label:Label = resource_icons[r].label;
			var current_value:int = int(label.text);
			var target:int = target_inventory[r];
			
			var tween:Tween = create_tween();
			tween.tween_method(set_label_text.bind(label), current_value, target, .65)


func set_label_text(target:int, label:Label)->void:
	label.text = str(target)


func _on_player_resource_changed(_resource: String) -> void:
	update();
