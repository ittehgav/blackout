extends Item

class_name ResourceContainer

@export_enum("food", "fuel", "juice", "scrap", "chips") var resource:String;

var description:String;

func _ready()->void:
	assert(material is ShaderMaterial)
	material.set_shader_parameter("base_color", Index.get_color(resource));
	description = "Holds up to " + str(self["capacity"]) + " " + Index.get_color_tag(resource) + resource + "."


func drop_on_container(target:ResourceContainer)->bool:
	## returns true if stack is of scrap or food and has been emptied
	var remaining_space = target.capacity - target.stack_size;
	if remaining_space > stack_size:
		target.stack_size += stack_size;
		stack_size = 0;
		if "raw_stack" in self:
			queue_free()
			return true;
		return false
	else:
		stack_size -= remaining_space;
		target.stack_size += remaining_space;
		return false

	
