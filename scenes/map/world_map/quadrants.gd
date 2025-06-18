extends "res://scenes/map/world_map/world_gen.gd"

class_name WorldMapPlane

@export var player_camera:Camera2D;


var camera_top_margin:int;
var camera_right_margin:int;
var camera_bottom_margin:int;
var camera_left_margin:int;



func _ready() -> void:
	await world_map.ready;
	super();
	world_map.update_light();
	set_camera_margins()
	Entities.in_map_player.position = Vector2(500, 500)
	Entities.world_map.finished_generating.emit()


func set_corner_quadrants()->void:
	all_quadrants.sort_custom(sort_top_left_to_bottom_right);

	top_left_quadrant = all_quadrants[0];
	bottom_right_quadrant = all_quadrants[3];

func set_camera_margins()->void:
	set_corner_quadrants()

	var x_quadrant_extension:float = quarter_tile_map_size.x * cell_size;
	var y_quadrant_extension:float = quarter_tile_map_size.y * cell_size;

	
	var window_size:Vector2 = get_window().size;
	camera_top_margin = top_left_quadrant.global_position.y + window_size.y / player_camera.zoom.y;
	camera_right_margin = bottom_right_quadrant.global_position.x + x_quadrant_extension - window_size.x / player_camera.zoom.x;
	camera_bottom_margin = bottom_right_quadrant.global_position.y + y_quadrant_extension - window_size.y / player_camera.zoom.y;
	camera_left_margin = top_left_quadrant.global_position.x + window_size.x/player_camera.zoom.x;
	$check_quadrant_shift.start();




func update_fog()->void:
	## PLAYER GETS REPARENTED AS THEY MOVE QUADRANTS
	## may stutter if trying to refresh right as player crosses quadrants
	## add a little buffer zone so you can't go back and forth too quickly? 
	var player_grid_position:Vector2i = Vector2i(Entities.in_map_player.position/cell_size);
	var sight_radius:float = Entities.player.sight_range/cell_size + 5;
	
	for x in range(sight_radius * 2):
		for y in range(sight_radius * 2):
			var cell:Vector2i = Vector2i(x - sight_radius, y - sight_radius);
			var distance:float = cell.distance_to(Vector2.ZERO);
			var cell_position:Vector2 = cell + player_grid_position;
			
			var dict:Dictionary = get_quadrant_cell(cell_position);
			var quadrant:WorldMapQuadrant = dict.quadrant;
			cell = dict.cell;
			if distance < sight_radius - 3:
				quadrant.fog_tile_map.set_cell(cell, 0, Vector2(2, 0));
				quadrant.off_sight_tile_map.erase_cell(cell);
			else:
				quadrant.off_sight_tile_map.set_cell(cell, 0, Vector2.ZERO);
				if distance < sight_radius + 1:
					if quadrant.fog_tile_map.get_cell_atlas_coords(cell) != Vector2i(2, 0):
						quadrant.fog_tile_map.set_cell(cell, 0, Vector2(1, 0));
			

func get_quadrant_cell(cell_position:Vector2i)->Dictionary:
	var quadrant:WorldMapQuadrant = Entities.in_map_player.current_quadrant;
	var dict:Dictionary = {
		"quadrant":quadrant,
		"cell":cell_position
	}
	var x_overshoot:bool = cell_position.x >= quarter_tile_map_size.x;
	var y_overshoot:bool = cell_position.y >= quarter_tile_map_size.y;
	
	var x_undershoot:bool = cell_position.x < 0;
	var y_undershoot:bool = cell_position.y < 0;
	
	var x_crossing:bool = x_undershoot or x_overshoot;
	var y_crossing:bool = y_undershoot or y_overshoot;
	
	if x_crossing or y_crossing:
		if x_overshoot:
			dict.cell.x -= quarter_tile_map_size.x;
		elif x_undershoot:
			dict.cell.x += quarter_tile_map_size.x;
		
		if y_overshoot:
			dict.cell.y -= quarter_tile_map_size.y;
		elif y_undershoot:
			dict.cell.y += quarter_tile_map_size.y;
		
		if x_crossing and y_crossing:
			dict.quadrant = quadrant.diagonal_quadrant
		elif x_crossing:
			dict.quadrant = quadrant.x_adjacent_quadrant
		else:
			dict.quadrant = quadrant.y_adjacent_quadrant
	return dict
		

func check_quadrant_shift()->void:
	if player_camera.global_position.y < camera_top_margin:
		shift_quadrants(Vector2.UP)
	elif player_camera.global_position.y > camera_bottom_margin:
		shift_quadrants(Vector2.DOWN)
	if player_camera.global_position.x > camera_right_margin:
		shift_quadrants(Vector2.RIGHT)
	elif player_camera.global_position.x < camera_left_margin:
		shift_quadrants(Vector2.LEFT)
		

func shift_quadrants(way:Vector2)->void:
	match way:
		Vector2.UP:
			var y_shift:float = quarter_tile_map_size.y * cell_size * 2
			
			bottom_right_quadrant.position.y -= y_shift;
			bottom_right_quadrant.x_adjacent_quadrant.position.y -= y_shift;
		Vector2.RIGHT:
			var x_shift:float = quarter_tile_map_size.x * cell_size * 2;
			
			top_left_quadrant.position.x += x_shift;
			top_left_quadrant.y_adjacent_quadrant.position.x += x_shift;
		Vector2.DOWN:
			var y_shift:float = quarter_tile_map_size.y * cell_size * 2
			
			top_left_quadrant.position.y += y_shift
			top_left_quadrant.x_adjacent_quadrant.position.y += y_shift
		Vector2.LEFT:
			var x_shift:float = quarter_tile_map_size.x * cell_size * 2;
			
			bottom_right_quadrant.position.x -= x_shift;
			bottom_right_quadrant.y_adjacent_quadrant.position.x -= x_shift;

	set_camera_margins();

func sort_top_left_to_bottom_right(a: WorldMapQuadrant, b: WorldMapQuadrant) -> bool:
	if a.global_position.y < b.global_position.y:
		return true
	if a.global_position.y > b.global_position.y:
		return false
	return a.global_position.x < b.global_position.x
