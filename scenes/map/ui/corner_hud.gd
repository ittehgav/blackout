extends PanelContainer


@export var food_label:Label
@export var money_label:Label
@export var fuel_label:Label

@export var juice_label:Label
@export var scrap_label:Label
@export var chips_label:Label

func _ready():
	Entities.player.resources_changed.connect(refresh_values);
	refresh_values()

func refresh_values():
	update_resource_label(food_label, "food");
	update_resource_label(money_label, "money");
	update_resource_label(fuel_label, "fuel");

	update_resource_label(juice_label, "juice");
	update_resource_label(scrap_label, "scrap");
	update_resource_label(chips_label, "chips");

func update_resource_label(label:Label, resource:String)->void:
	var current_value:int;
	if resource == "money":
		current_value = int(label.text.split("$")[1])
	else:
		current_value = int(label.text.split(": ")[1])
		
	var new_value = Entities.player.inventory[resource];
	
	if current_value != new_value:
		label.text = resource.capitalize() + ": ";
		if resource == "money":
			label.text += "$";
		label.text += str(new_value)
	
		var change_color:Color;
		if current_value < new_value:
			change_color = Color.RED;
		else:
			change_color = Color.GREEN;
		
		label.modulate  = change_color;
		var tween = create_tween();
		tween.tween_interval(.75)
		tween.tween_property(label, "modulate", Color.WHITE, .5)
	
	
