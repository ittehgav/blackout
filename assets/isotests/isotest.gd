extends Node2D
@export var nav_tiles:TileMapLayer;

@export var sprite:Sprite2D;
@onready var grid:AStarHexGrid2D = AStarHexGrid2D.new();

func _ready()->void:
	grid.setup_hex_grid(nav_tiles);
	var path:PackedVector2Array = get_cell_path();
	var tween:Tween = create_tween();
	for cell:Vector2 in path:
		tween.tween_property(sprite, "position", cell, .25)

func get_cell_path()->PackedVector2Array:
	var from_cell: = nav_tiles.local_to_map(Vector2.ZERO);
	var to_cell: = nav_tiles.local_to_map(Vector2(1280, 720))
	
	return grid.get_path(from_cell, to_cell)
