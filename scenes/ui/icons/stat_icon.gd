extends Icon

class_name StatIcon

var description:String;



@export var from_player:bool=false

@export var bg:ColorRect;
@export var outline:ReferenceRect

@export_enum("max_hp", "attack", "defense", "agility", "technique") var stat:String="max_hp";

var floating:bool=false;
func _ready()->void:
	var stat_color:Color = Index.stat_colors[stat]
	default_color = stat_color;
	highlight_color = stat_color;
	highlight_color.v += .25
	if floating:
		## make this cleaner somehow:?
		
		texture = Index.textures[stat+"_floating_icon"];
		modulate = stat_color - Color(0, 0, 0, .5)
		custom_minimum_size = Vector2(24, 24)
		size = Vector2(24, 24)
	else:
		outline.show();
		bg.show();
		
		texture = Index.textures.icons[stat];
		modulate = Index.stat_colors[stat]
		label.add_theme_color_override("font_color", modulate)
		
