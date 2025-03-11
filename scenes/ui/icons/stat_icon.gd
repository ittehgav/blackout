extends Icon

class_name StatIcon

var description:String;
var tooltip_name_color:Color;

@export_enum("max_hp", "attack", "defense", "move_speed", "technique") var stat="max_hp";

func _ready():
	texture = Icons[stat];
	material.set_shader_parameter("base_color", Icons.stat_colors[stat]);
	name = stat.capitalize()
	
	tooltip_name_color = Icons.stat_colors[stat];
	if stat == "map_hp":
		name = "Max HP";
	if stat == "move_speed":
		name = "Movement Speed"
		
	description = Icons.stat_descriptions[stat]
