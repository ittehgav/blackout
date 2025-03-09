extends ColorRect

@export var icon:TextureRect
@export var panel:Panel;


@export_enum("food", "fuel", "money", "juice", "scrap", "chips") var resource="food";

func _ready():
	icon.texture = Icons[resource];
	material.set_shader_parameter("base_color", Icons.resource_colors[resource])
	material.set_shader_parameter("base_color", Icons.resource_colors[resource]);
