extends Node2D;
## building will not be all-encopassing enough a word i thinks but its fine for now
class_name Building

signal daily_reset;

## some (if not most buildings) will just not have inventories or roster, if they
## have no operations that need them to have one;
@export var inventory:NpcInventory;
@export var roster:BuildingRoster

## sizing within the settlement view will be defind by texture sizes themseves?
@export var background_texture:Texture;
@export var front_porch_texture:Texture;


@export_group("Common Operations")
@export var trade_option:bool; ## trade with the building's inventory
@export var recruit_option:bool; ## recruit from the building's roster
