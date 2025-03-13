extends Icon

class_name StatIcon

var description:String;
var tooltip_name_color:Color;

@export var adjacent_items:Array[CanvasItem];


@export_enum("max_hp", "attack", "defense", "move_speed", "technique") var stat="max_hp";


func _ready():
	texture = Meta.icons[stat];
	material.set_shader_parameter("base_color", Meta.stat_colors[stat]);
	name = stat.capitalize()
	
	tooltip_name_color = Meta.stat_colors[stat];
	if stat == "map_hp":
		name = "Max HP";
	if stat == "move_speed":
		name = "Movement Speed"
		
	description = Meta.stat_descriptions[stat]
	for item in adjacent_items:
		item.modulate = Meta.stat_colors[stat].lightened(.2)
		
	$panel.custom_minimum_size = Vector2(size.x + 4, size.y + 4)
