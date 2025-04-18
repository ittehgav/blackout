extends Icon

class_name StatIcon

var description:String;
var tooltip_name_color:Color;

@export var adjacent_items:Array[CanvasItem];


@export_enum("max_hp", "attack", "defense", "agility", "technique") var stat:String="max_hp";


func _ready()->void:
	texture = Index.icons[stat];
	material.set_shader_parameter("base_color", Index.stat_colors[stat]);
	name = stat.capitalize()
	
	tooltip_name_color = Index.stat_colors[stat];
	if stat == "map_hp":
		name = "Max HP";
		
	description = Index.stat_descriptions[stat]
	for item in adjacent_items:
		item.modulate = Index.stat_colors[stat].lightened(.2)
		
	$panel.custom_minimum_size = Vector2(size.x + 4, size.y + 4)
