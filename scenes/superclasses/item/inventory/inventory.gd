extends Node2D

## any settlement or party has an inventory
class_name Inventory;

@export_subgroup("Resources")
@export var food:int;
@export var money:float;
@export var fuel:int;

@export var juice:int;
@export var scrap:int;
@export var chips:int;

@export_subgroup("Items")
@export var consumables:Array[Consumable];
@export var trinkets:Array[Trinket];

@export_subgroup("Equipment")
@export var weapons:Array[Weapon];
@export var armor:Array[Armor];


func _on_child_entered_tree(node: Node) -> void:
	## INVENTORIES AND ROSTERS JUST NEED TO HAVE THE UNITS AS CHILDREN TO PROPERLY CATEGORIZE THEM
	assert(node is Item)
	if node is Consumable:
		consumables.push_back(node);
	elif node is Trinket:
		trinkets.push_back(node);
	elif node is Armor:
		armor.push_back(node);
	elif node is Weapon:
		weapons.push_back(node);

			

func _on_child_exiting_tree(node: Node) -> void:
	assert(node is Item)
	if node is Consumable:
		consumables.erase(node);
	elif node is Trinket:
		trinkets.erase(node);
	elif node is Armor:
		armor.erase(node);
	elif node is Weapon:
		weapons.erase(node);
