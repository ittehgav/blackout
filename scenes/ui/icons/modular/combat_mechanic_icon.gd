extends Icon
class_name CombatMechanicIcon

@export var texture_under:TextureRect
var stat:String;

@export var mechanic:Mechanics;
enum Mechanics{
	damage,
	range,
	stun,
	knockback,
	stat_up,
	stat_down,
	cooldown,
	duration
}
@export var mechanic_textures:Dictionary[Mechanics, Texture]
@export var mechanic_colors:Dictionary[Mechanics, Color]

func setup()->void:
	## NEED MECHANIC AND ADDITIONAL VALUES TO BE SET BEFORE ENTERING TREE
	texture = get_icon_texture()
	
	var color:Color = get_color()
	default_color = color;
	highlight_color = color;
	highlight_color.v += .25;
	
	
	
	modulate = default_color;
	if label:
		label.add_theme_color_override("font_color", default_color)
		if len(label.text) <= 5:
			label.add_theme_font_size_override("font_size", 48)


func get_color()->Color:
	return mechanic_colors[mechanic]
func get_icon_texture()->Texture:
	if mechanic in [Mechanics.stat_up, Mechanics.stat_down]:
		texture_under.texture = Index.textures.icons[stat]
	return mechanic_textures[mechanic]
