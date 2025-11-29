extends TileMapLayer

class_name NavigationGrid

var astar_grid:AStarHexGrid2D;

const CELL_FREE = Vector2i.ZERO
const CELL_TAKEN = Vector2i(1, 0);

func _ready()->void:
	astar_grid = AStarHexGrid2D.new()
	astar_grid.setup_hex_grid(self);

func occupy_cell(source:IsoFighter)->void:
	var to_free:Vector2i = source.current_cell;
	set_cell(to_free, 0, CELL_FREE)
	var cell:Vector2i = local_to_map(source.movement_target);
	source.current_cell = cell;
	set_cell(cell, 0, CELL_TAKEN)
	
func get_next_cell_in_path(target:IsoFighter)->Vector2:
	var from_cell:Vector2 = local_to_map(target.position);
	var to_cell:Vector2 = local_to_map(target.target.position)
	return astar_grid.get_path(from_cell, to_cell)[1]

func hex_axial_distance(a: Vector2i, b: Vector2i) -> int:
	var dq:int = a.x - b.x
	var dr:int = a.y - b.y
	return (abs(dq) + abs(dr) + abs(dq + dr)) / 2

func cell_distance(p1:Vector2, p2:Vector2)->int:
	var a:Vector2i = local_to_map(p1)
	var b:Vector2i = local_to_map(p2)

	return hex_axial_distance(a, b)

func spot_taken(spot:Vector2)->bool:
	var cell:Vector2i = local_to_map(spot);
	return get_cell_atlas_coords(cell) == CELL_TAKEN
