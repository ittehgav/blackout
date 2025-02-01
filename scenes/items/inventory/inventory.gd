extends Node

## any settlement or party has an inventory
class_name Inventory;

@export_subgroup("Basic Resources")
@export var food:float;
@export var money:float;
@export var fuel:float;

@export var juice:float;
@export var scrap:float;

@export_subgroup("Items")
@export var usable_items:Array[Item];

@export_subgroup("Equipment")
@export var weapons:Array[Node];
@export var armor:Array[Node];
@export var accessories:Array[Node];
