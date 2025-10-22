extends Button

@export var perk_icon:TextureRect;
@export var perk_name:Label;
@export var perk_description:RichTextLabel;

func build_option(perk:Perk)->void:
	add_child(perk);
	await perk.ready
	self_modulate = perk.title_color + Color(.2, .2, .2);
	
	## so it runs _ready and does RNG stuff before building
	
	perk_icon.texture = perk.icon;
	perk_icon.modulate = perk.title_color.darkened(.2)
	
	perk_name.text = perk.name;
	perk_description.text = perk.description;
	perk_name.add_theme_color_override("font_color", perk.title_color )
