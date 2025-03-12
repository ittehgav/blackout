extends Icon

class_name ResourceIcon

@export var panel:Panel;
var tooltip_name_color:Color;
var description:String;
@export var show_tooltip:bool;
@export var in_trade:bool;

@export_enum("food", "fuel", "money", "juice", "scrap", "chips") var resource="food";

func _ready():
	texture = Icons[resource];
	material.set_shader_parameter("base_color", Icons.resource_colors[resource])
	
	if show_tooltip:
		name = resource.capitalize();
		tooltip_name_color = Icons.resource_colors[resource];
		description = Icons.resource_descriptions[resource]
	
