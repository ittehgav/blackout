extends Node2D

class_name Location

var pending_reset:bool=true;
## refreshes will only be effectively made when dynamic data from the location is called for

@export_range(1, 3) var size:int = 1;


@export var reset_cycle:int=7;
var days_since_last_cycle:int=0

## only for full-settlement buildings
@export_group("Size 3 Things")
@export var map_texture:Texture;
@export var map_texture_modulate:Color;
@export var bgm_key:String; ## for when arenas/multi_stage things?
@export var icon_texture:Texture;

func refresh()->void:
	printerr("REFRESHMIOSSING ", name)
