extends Item

class_name ResourceContainer

@export_enum("food", "fuel", "juice", "scrap", "chips") var resource:String;

var description:String;

func _ready()->void:
	assert(material is ShaderMaterial)
	material.set_shader_parameter("base_color", Index.get_color(resource));
	if "raw_stack" in self:
		if "mirror_only" in self:
			description = Index.resource_colored_name(resource) + " is a liquid, it will go to waste if left outside of a [u]container.[/u]"
		else:
			description = "Stack of up to " + str(self["capacity"]) + " " + Index.resource_colored_name(resource) + "."
	else:
		description = "Holds up to " + str(self["capacity"]) + " " + Index.resource_colored_name(resource) + "."


func drop_on_container(target:ResourceContainer, sfx_player:SfxPlayer)->bool:
	## returns true if stack is a raw_stack and has been emptied
	var remaining_space:int = target.space_left();
	if remaining_space and stack_size:
		target.mirror.highlight_stack_label()
		if remaining_space > stack_size:
			target.stack_size += stack_size;
			stack_size = 0;
			play_deposit_sfx(stack_size, sfx_player);
			if "raw_stack" in self:
				free()
				return true;
			return false
		else:
			stack_size -= remaining_space;
			target.stack_size += remaining_space;
			play_deposit_sfx(remaining_space, sfx_player);
			return false
	return false

func play_deposit_sfx(amount_deposited:int, sfx_player:SfxPlayer)->void:
	match resource:
		"food":
			if amount_deposited <= 10:
				sfx_player.play_sound_by_key("deposit_food_small");
			else:
				sfx_player.play_sound_by_key("deposit_food_big");
		"fuel", "juice":
			if amount_deposited <= 10:
				sfx_player.play_sound_by_key("deposit_liquid_small");
			else:
				sfx_player.play_sound_by_key("deposit_liquid_big");
		"scrap":
			if amount_deposited <= 10:
				sfx_player.play_sound_by_key("deposit_scrap_small");
			else:
				sfx_player.play_sound_by_key("deposit_scrap_big")
		"chips":
			sfx_player.play_sound_by_key("deposit_chips")
			
func send_to_containers(sfx:SfxPlayer)->bool:
	## returns true if the container has been emptied and the ItemMirror can go away
	var available_containers:Array[ResourceContainer] = []
	for c in Entities.player.inventory.containers:
		if c.resource == resource:
			available_containers.append(c);
	available_containers.sort_custom(capacity_sort);
	var stack:int = stack_size;
	for c:ResourceContainer in available_containers:
		var space:int = c.space_left();
		if space >= stack_size:
			c.stack_size += stack_size;
			play_deposit_sfx(stack, sfx);
			tree_exited.connect(mirror.display.item_dropped.emit.bind(mirror), CONNECT_ONE_SHOT);
			c.mirror.highlight_stack_label()
			queue_free();
			return true;
		else:
			stack_size -= space;
			c.stack_size += space;
			c.mirror.highlight_stack_label();
	play_deposit_sfx(stack - stack_size, sfx);
	return false;



	
func space_left()->int:
	if self["capacity"] == 0:
		## for when a stack is mirror_only and can carry an infinite amount of the resource
		return -1;
	return self["capacity"] - stack_size;

func empty_storage(sfx:SfxPlayer)->Array[ResourceContainer]:
	var stack_scene:PackedScene = Index[resource + "_stack_scene"];
	
	var current_stacks:Array[ResourceContainer] = []
	var initial_stack:int = stack_size;
	for item:ResourceContainer in Entities.player.inventory.containers:
		if "raw_stack" in item and item.resource == resource and item.space_left():
			current_stacks.append(item);
	
	for stack:ResourceContainer in current_stacks:
		if stack_size:
			if stack.capacity == 0:
				stack.stack_size += stack_size
				stack_size = 0;
				stack.mirror.highlight_stack_label()
			else:
				if stack.space_left() >= stack_size:
					stack.stack_size += stack_size;
					stack_size = 0;
					stack.mirror.highlight_stack_label()
				else:
					var to_add:int = stack.space_left()
					stack.stack_size += to_add;
					stack_size -= to_add;
					stack.mirror.highlight_stack_label()
					
	var new_stacks:Array[ResourceContainer];
	while stack_size:
		var stack:ResourceContainer = stack_scene.instantiate();
		if "mirror_only" in stack:
			stack.stack_size = stack_size
			stack_size = 0;
		else:
			if stack.capacity < stack_size:
				stack.stack_size = stack.capacity;
				stack_size -= stack.capacity;
			else:
				stack.stack_size = stack_size;
				stack_size = 0;
		mirror.highlight_stack_label()
		Entities.player.inventory.add_child(stack);
		new_stacks.append(stack)

	play_deposit_sfx(initial_stack - stack_size, sfx);
	return new_stacks;

func check_empty()->bool:
	if stack_size == 0 and "raw_stack" in self:
		queue_free();
		return true
	return false;

func capacity_sort(a:ResourceContainer, b:ResourceContainer)->bool:
	## sorts first by capacity then by space left
	if a.capacity > b.capacity:
		return true
	if b.capacity > a.capacity:
		return false
	return a.space_left() > b.space_left();
