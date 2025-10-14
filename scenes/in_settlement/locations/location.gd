extends Node2D

class_name Location

signal daily_reset
@export_range(1, 3) var size:int = 1;

## only for full-settlement buildings
@export_group("Size 3 Things")
@export var map_texture:Texture;
@export var map_texture_modulate:Color;
@export var bgm_key:String; ## for when arenas/multi_stage things?
@export var icon_texture:Texture;
