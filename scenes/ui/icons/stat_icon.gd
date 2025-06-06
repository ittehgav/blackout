extends Icon

class_name StatIcon

var description:String;
var tooltip_name_color:Color;
@export var panel:Panel;

@export var adjacent_items:Array[CanvasItem];
@export var from_player:bool=false


@export_enum("max_hp", "attack", "defense", "agility", "technique") var stat:String="max_hp";

var floating:bool=false;
func _ready()->void:
	if floating:
		## make this cleaner somehow:?
		
		texture = Index[stat+"_floating_icon"];
		panel.hide()
		modulate = Index.stat_colors[stat] - Color(0, 0, 0, .2)
		custom_minimum_size = Vector2(24, 24)
		size = Vector2(24, 24)
	else:
		texture = Index.icons[stat];

		material.set_shader_parameter("base_color", Index.stat_colors[stat]);
		name = stat.capitalize()
		
		tooltip_name_color = Index.stat_colors[stat];
		if stat == "map_hp":
			name = "Max HP";
			
		description = Index.stat_descriptions[stat]
		for item in adjacent_items:
			if item is Label:
				item.add_theme_color_override("font_color", Index.stat_colors[stat].lightened(.2))
				if from_player:
					item.text = str(Entities.player.combat_stats[stat]);
			
		$panel.custom_minimum_size = Vector2(size.x + 4, size.y + 4)
