extends Sprite2D

class_name Item;


## will have negative values if it's not in an inventory;
@export var inventory_position:Vector2=Vector2(-1, -1);

@export var stack_size:int=1;
