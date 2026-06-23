extends Consumable

const size_x = 2;
const size_y = 1;

const rarity = 2;

func get_description()->String:
	return "Use to gain a random amount of " + Resources.resource_colored_name("food")+"."

func use()->void:
	var roll:int = randi_range(25, 50);
	mirror.display.board_shake()
	while roll:
		var stack:ResourceContainer = Index.scenes.items.food_stack.instantiate();
		if roll >= 5:
			roll -= 5;
			## if there's no room the food is just gone and that ok
			stack.stack_size = 5;
		else:
			stack.stack_size = roll;
			roll = 0;
		mirror.display.throw_in_inventory(stack, self)
		if stack.mirror and stack.mirror.inventory_position != Vector2i(-1, -1):
			stack.match_mirror()

	var player:Player = get_tree().get_first_node_in_group("player")
	player.resource_changed.emit("food")
	
	
