extends Item

class_name ResourceContainer

@export_enum("food", "fuel", "juice", "scrap", "chips") var resource:String;
@export var raw_stack:bool=false;
@export var mirror_only:bool=false
@export var storage:bool=false;

var description:String;
var hint_description:String;

func _ready()->void:
	set_hint_data();


func set_hint_data()->void:
	assert(material is ShaderMaterial)
	hint_description = "[right-click] to store"
	material.set_shader_parameter("base_color", Index.get_color(resource));
	if raw_stack:
		if mirror_only:
			description = Index.resource_colored_name(resource) + " is a liquid, it will go to waste if left outside of a [u]container.[/u]"
		else:
			description = "Stack of up to " + str(self["capacity"]) + " " + Index.resource_colored_name(resource) + "."
	else:
		hint_description = "[right-click] to empty"
		description = "Holds up to " + str(self["capacity"]) + " " + Index.resource_colored_name(resource) + "."




	
func space_left()->int:
	if self["capacity"] == 0:
		## for when a stack is mirror_only and can carry an infinite amount of the resource
		return -1;
	return self["capacity"] - stack_size;

func check_empty()->bool:
	if stack_size == 0 and raw_stack:
		return true
	return false;

func capacity_sort(a:ResourceContainer, b:ResourceContainer)->bool:
	## sorts first by capacity then by space left
	if a.capacity > b.capacity:
		return true
	if b.capacity > a.capacity:
		return false
	return a.space_left() > b.space_left();
