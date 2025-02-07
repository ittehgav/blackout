extends Node

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

@export_subgroup("Equipment")
@export var weapons:Array[Weapon];
@export var armor:Array[Armor];
@export var trinkets:Array[Trinket];
