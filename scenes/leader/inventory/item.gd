extends Sprite2D

class_name Item;
var mirror:ItemMirror;


@export var inventory_position:Vector2=Vector2(-1, -1);

@export var stack_size:int=1;

func match_mirror()->void:
	inventory_position = mirror.inventory_position;
	if self not in mirror.display.inventory.items:
		mirror.display.inventory.add_item(self);

func get_description()->String:
	return "DESCRIPTION MISSOMG"
