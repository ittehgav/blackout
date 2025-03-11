extends Icon

class_name ResourceIcon

@export var panel:Panel;


@export_enum("food", "fuel", "money", "juice", "scrap", "chips") var resource="food";

func _ready():
	texture = Icons[resource];
	material.set_shader_parameter("base_color", Icons.resource_colors[resource])


func _on_mouse_entered() -> void:
	print("menter?")
