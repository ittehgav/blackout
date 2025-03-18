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
