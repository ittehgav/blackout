extends TileMapLayer;

@export var props_tiles:TileMapLayer
@export var roadside_tiles:TileMapLayer;
@export var highlight_tiles:TileMapLayer;

func _ready()->void:
	Entities.road = self;



var to_apply_terrain:Array[Vector2i];

var road_cells:Array[Vector2i];
var roadside:Array[Vector2i];
var props_slots:Array[Vector2i];
func generate_roads(settlements:Array[Settlement])->void:
	for settlement:Settlement in settlements:
		for neighbor:Settlement in settlement.neighbors:
			if settlement not in neighbor.neighbor_paths:
				connect_neighbors(settlement, neighbor);
	
	for spot:Vector2i in road_cells:
		## so props don't appear in the middle of the road
		props_slots.erase(spot)
	roadside_tiles.set_cells_terrain_connect(roadside, 0, 0)
	props_tiles.set_cells_terrain_connect(props_slots, 0, 0)


func connect_neighbors(l1:Settlement, l2:Settlement)->void:
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
	
	for spot:Vector2i in final_path:
		for x in range(-1, 2):
			for y in range(-1, 2):
				var to_add: = Vector2i(spot.x + x, spot.y + y);
				if to_add not in roadside:
					roadside.append(to_add);

	
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
			
	const prop_offset = 5
	if dx: ## horizontal line = spots offset on the Y axis
		for spot:Vector2i in path:
			road_cells.append(spot) ## catching road cells to prevent overlapping with props
			var slot_1:Vector2i = Vector2i(spot.x, spot.y - prop_offset - 1)
			var slot_2:Vector2i = Vector2i(spot.x, spot.y + prop_offset)
			if slot_1 not in props_slots:
				props_slots.append(slot_1);
			if slot_2 not in props_slots:
				props_slots.append(slot_2);
	else: ## vertical line = spots offset on the X axis
		for spot:Vector2i in path:
			road_cells.append(spot)
			var slot_1:Vector2i = Vector2i(spot.x - prop_offset - 1, spot.y)
			var slot_2:Vector2i = Vector2i(spot.x + prop_offset, spot.y)
			if slot_1 not in props_slots:
				props_slots.append(slot_1);
			if slot_2 not in props_slots:
				props_slots.append(slot_2);

	return path
