extends TileMapLayer;

@export var origin:Location;

@export var props_tiles:TileMapLayer
@export var roadside_tiles:TileMapLayer;
@export var highlight_tiles:TileMapLayer;

func _ready()->void:
	Entities.road = self;


var roadside:Array[Vector2i];

func generate_roads(locations:Array[Location])->void:
	origin.neighbors = [origin.neighbors[0]]
	for location:Location in locations:
		for neighbor:Location in location.neighbors:
			if location not in neighbor.neighbor_paths:
				connect_neighbors(location, neighbor);
	


func connect_neighbors(l1:Location, l2:Location)->void:
	var start:Vector2i = local_to_map(l1.position)
	var end:Vector2i = local_to_map(l2.position)
	
	## the longer axis is the one that the road draws first
	var x_first:bool = abs(start.x - end.x) > abs(start.y - end.y);
	
	var corner:Vector2;
	if x_first:
		corner = Vector2i(end.x, start.y)
	else:
		corner = Vector2i(start.x, end.y);
	
	var path1:Array[Vector2i] = get_straight_line(start, corner);
	var path2:Array[Vector2i] = get_straight_line(corner, end);
	path1.remove_at(len(path1)-1)
	var final_path:PackedVector2Array = path1 + path2;
	l1.neighbor_paths[l2] = final_path;
	var reversed_path: = final_path.duplicate()
	reversed_path.reverse();
	l2.neighbor_paths[l1] = reversed_path; 
	
	
	set_cells_terrain_path(final_path, 0, 0);
	
	


func get_straight_line(from:Vector2i, to:Vector2i)->Array[Vector2i]:
	var path:Array[Vector2i];
	var dx:= int(abs(to.x - from.x));
	var dy:= int(abs(to.y - from.y))
	
	var sx: = -1 if from.x > to.x else 1
	var sy: = -1 if from.y > to.y else 1
	var err: = dx - dy
	
	var x: = from.x
	var y: = from.y
	while true:
		var coords:= Vector2i(x, y);
		path.append(coords)
		if x == to.x && y == to.y:
			break
		var e2: = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy
	return path
