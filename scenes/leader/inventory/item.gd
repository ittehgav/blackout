extends Sprite2D

class_name Item;
var mirror:ItemMirror;

var applied_modifier:ItemModifier

@export var inventory_position:Vector2=Vector2(-1, -1);

@export var stack_size:int=1;

## get applied to the price before the shop modifiers, may be negative/less than 1
var price_change:int; 
var price_multiplier:float=1;

func match_mirror()->void:
	inventory_position = mirror.inventory_position;
	if self not in mirror.display.inventory.items:
		mirror.display.inventory.add_item(self);

func get_description()->String:
	return "DESCRIPTION MISSOMG"

func get_mirror_color()->Color:
	## overrideable not only by the type but by individual items btw
	return Color.PURPLE;
