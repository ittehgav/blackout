extends Item

class_name ResourceContainer

@export_enum("food", "fuel", "juice", "scrap", "chips") var resource:String;

func _ready()->void:
	assert(material is ShaderMaterial)
	material.set_shader_parameter("base_color", Index.get_color(resource));
