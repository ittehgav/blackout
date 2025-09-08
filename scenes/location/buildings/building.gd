extends Node2D;
## building will not be all-encopassing enough a word i thinks but its fine for now
class_name Building

signal daily_reset;

## only for full-settlement buildings
@export var map_texture:Texture;
@export var map_texture_modulate:Color;
@export var icon_texture:Texture;
## size = thirds of the space the building takes up, a size 3 bulding
## always takes up the whole settlement
@export_range(1, 3) var size:int = 1;

## theres gotta be a cleaner way to do this?
@export var front_porch_scene:PackedScene

## some (if not most buildings) will just not have inventories or roster, if they
## have no operations that need them to have one;
@export var inventory:NpcInventory;
@export var roster:BuildingRoster



@export_group("Common Operations")
@export var trade_option:bool; ## trade with the building's inventory
@export var recruit_option:bool; ## recruit from the building's roster
