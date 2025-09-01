extends VBoxContainer
class_name ResourcesDropdown

@export var target_inventory:Inventory;

@export var costs:Control;
@export var food_cost:Label;
@export var fuel_cost:Label;

@export var resource_hboxes:Dictionary[String, HBoxContainer]
@export var resource_icons:Dictionary[String, ResourceIcon]

@export var show_travel_cost:bool=false;

func _ready()->void:
	if target_inventory:
		setup();
	
func setup()->void:
	for r:String in Index.all_resources:
		resource_icons[r].source = target_inventory;
		
	if show_travel_cost:
		costs.show()
		var food_color:Color = Index.get_color("food");
		var fuel_color:Color = Index.get_color("fuel")
		

		
		food_cost.add_theme_color_override("font_color", food_color)
		fuel_cost.add_theme_color_override("font_color", fuel_color)
	update();

func update(concurring_inventories:Array[Inventory] = [])->void:
	## concurring inventories is so you can see your resources you have 0
	## of when trading with someone who has it
	if show_travel_cost:
		var costs:Dictionary = Entities.player.travel_upkeep_cost(true)
		fuel_cost.text = "-"+str(int(costs.fuel))+"/h";
		food_cost.text = "-"+str(int(costs.food))+"/h";
	
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
