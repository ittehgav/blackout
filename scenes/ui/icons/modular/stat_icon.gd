extends Icon

class_name StatIcon

var description:String;

## only ever gets shown in dropdowns or floating?

@export_enum("max_hp", "attack", "defense", "agility", "technique") var stat:String="max_hp";


func get_icon_texture()->Texture:
	return Index.textures.icons[stat]

func get_color()->Color:
	return Index.get_color(stat)
