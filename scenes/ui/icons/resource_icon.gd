extends Icon

class_name ResourceIcon

@export var panel:Panel;
var tooltip_name_color:Color;
var description:String;
@export var show_tooltip:bool;
@export var in_trade:bool;

@export var adjacent_items:Array[CanvasItem];

@export_enum("food", "fuel", "money", "juice", "scrap", "chips") var resource:String="food";

func _ready()->void:
	texture = Meta.icons[resource];
	material.set_shader_parameter("base_color", Meta.resource_colors[resource])
	
	if show_tooltip:
		name = resource.capitalize();
		tooltip_name_color = Meta.resource_colors[resource];
		description = Meta.resource_descriptions[resource]
	else:
		$Tooltip.queue_free();
	
	for item in adjacent_items:
		item.modulate = Meta.resource_colors[resource]
		if item is Label:
			Entities.player.resources_changed.connect(set_count_label.bind(item))
			set_count_label(item);
		
func set_count_label(target:Label)->void:
	var value:int = Entities.player.inventory[resource];
	target.text = str(value);
