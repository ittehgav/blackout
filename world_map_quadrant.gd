extends Node2D
class_name WorldMapQuadrant;

@export var quadrant_n:int;

@export var small_props_node:Node2D;
@export var props_node:Node2D;

@export var tile_map:TileMapLayer;
@export var fog_tile_map:TileMapLayer
@export var off_sight_tile_map:TileMapLayer;

@export_group("boundaries")
@export var top_boundary:Area2D
@export var right_boundary:Area2D
@export var bottom_boundary:Area2D
@export var left_boundary:Area2D

@export var top_boundary_shape:CollisionShape2D;
@export var right_boundary_shape:CollisionShape2D;
@export var bottom_boundary_shape:CollisionShape2D;
@export var left_boundary_shape:CollisionShape2D;


@export_group("relative quadrants")
@export var x_adjacent_quadrant:WorldMapQuadrant
@export var y_adjacent_quadrant:WorldMapQuadrant;
@export var diagonal_quadrant:WorldMapQuadrant;

func _ready()->void:
	## COLLISION LAYER 9 = WORLD MAP QUADRANT BORDER HITBOXES
	var map_size:Vector2 = get_parent().quarter_tile_map_size;
	var cell_size:float = get_parent().cell_size
	
	top_boundary.position = Vector2.ZERO;
	top_boundary_shape.shape.a = Vector2.ZERO;
	top_boundary_shape.shape.b = Vector2(map_size.x*cell_size,0);

	right_boundary.position = Vector2(map_size.x*cell_size, 0);
	right_boundary_shape.shape.b = Vector2(0, map_size.y*cell_size);
	
	bottom_boundary.position = Vector2(map_size.x*cell_size, map_size.y*cell_size);
	bottom_boundary_shape.shape.b = Vector2(-map_size.x*cell_size, 0);
	
	left_boundary.position = Vector2(0, map_size.y*cell_size);
	left_boundary_shape.shape.b = Vector2(0, -map_size.y*cell_size);

	for x in map_size.x:
		for y in map_size.y:
			fog_tile_map.set_cell(Vector2i(x, y), 0, Vector2.ZERO);
			off_sight_tile_map.set_cell(Vector2i(x, y), 0, Vector2.ZERO);
	
