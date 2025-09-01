extends Icon

class_name DisciplineIcon;




@export_enum("charisma", "navigation", "tactics", "leadership", "scavenging") var discipline:String;

func _ready() -> void:
	default_color = modulate;
	
	highlight_color = default_color;
	highlight_color.v += .25
	
	label.add_theme_color_override("font_color", default_color)
	
	texture = Index.textures.icons[discipline];
	update()


func update()->void:
	label.text = str(Entities.player.disciplines[discipline]);
	
