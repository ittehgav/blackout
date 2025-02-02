extends Node

## any settlement or party has an inventory
class_name Inventory;

@export_subgroup("Resources")
@export var food:float;
@export var money:float;
@export var fuel:float;

@export var juice:float;
@export var scrap:float;

@export_subgroup("Items")
@export var consumables:Array[Consumable];

@export_subgroup("Equipment")
@export var weapons:Array[Weapon];
@export var armor:Array[Armor];
@export var trinkets:Array[Trinket];
