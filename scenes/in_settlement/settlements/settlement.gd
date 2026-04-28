@abstract 
class_name Settlement;
extends Node2D


var pending_refresh:bool=true;
## refreshes will only be effectively made when dynamic data from the location is called for

@export_range(1, 3) var size:int = 1;
@export var portrait:Texture;


@export var reset_cycle:int=7;
var days_since_last_cycle:int=0

## only for full-settlement buildings
@export_group("Size 3 Things")
@export var map_texture:Texture;
@export var map_texture_modulate:Color;
@export var bgm_key:String; ## for when arenas/multi_stage things?
@export var icon_texture:Texture;

@abstract func refresh()->void;

@onready var world_map:WorldMap = get_tree().get_first_node_in_group("world_map")

func hours_for_next_reset()->int:
	return (24 * (reset_cycle - days_since_last_cycle)) - world_map.current_hour

func day_passed()->void:
	days_since_last_cycle += 1;
	if days_since_last_cycle == reset_cycle:
		days_since_last_cycle = 0;
		pending_refresh = true
