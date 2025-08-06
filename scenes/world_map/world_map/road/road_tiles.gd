extends TileMapLayer

class_name RoadGrid;

func _ready()->void:
	Entities.road = self;

#func _unhandled_input(e:InputEvent)->void:
## TODO the player will be able to travel to any individual cell
	#if e is InputEventMouseMotion:
		#var cell:Vector2i = local_to_map(get_local_mouse_position());
		#var data:TileData = get_cell_tile_data(cell);
		#if data:
			#pass
		
@export var highlight_tiles:TileMapLayer;

var to_apply_terrain:Array[Vector2i];



func generate_roads(settlements:Array[Node])->void:
	clear()
	for settlement:Settlement in settlements:
		for neighbor:Settlement in settlement.neighbors:
			if settlement not in neighbor.neighbor_paths:
				connect_neighbors(settlement, neighbor);


func connect_neighbors(l1:Settlement, l2:Settlement)->void:
	var start:Vector2i = local_to_map(l1.position)/scale.x;
	var end:Vector2i = local_to_map(l2.position)/scale.x;
	
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


func highlight_travel(l1:Settlement, l2:Settlement)->void:
	if l2 in l1.neighbor_paths:
		highlight_path(l1, l2)
	else:
		var stops:Array[Settlement] = get_path_sequence(l1, l2);
		for i:int in len(stops) - 1:
			highlight_path(stops[i], stops[i + 1]);

func highlight_path(l1:Settlement, l2:Settlement)->void:
	assert(l2 in l1.neighbor_paths and l1 in l2.neighbor_paths)
	var path:PackedVector2Array = l1.neighbor_paths[l2];
	highlight_tiles.highlight_path(path)

func get_path_sequence(l1:Settlement, l2:Settlement)->Array[Settlement]:
	var queue:Array[Settlement];
	var visited:Array[Settlement];
	var parent:Dictionary;
	
	queue.append(l1);
	visited.append(l1);
	parent[l1] = null;
	
	while len(queue):
		var current:Settlement = queue.pop_front()
		
		if current == l2:
			var path:Array[Settlement];
			while current:
				path.append(current);
				current = parent[current];
			path.reverse();
			return path;
		
		for neighbor in current.neighbor_paths:
			if neighbor not in visited:
				visited.append(neighbor);
				parent[neighbor] = current;
				queue.append(neighbor);
	return[]

func clear_path_highlight()->void:
	highlight_tiles.clear();


func get_settlement_distance(s1:Settlement, s2:Settlement)->int:
	if s2 in s1.neighbor_paths:
		return len(s1.neighbor_paths[s2])
	else:
		var acm:int = 0;
		var sequence:Array[Settlement] = get_path_sequence(s1, s2);
		
		for i:int in len(sequence) - 1:
			var path:Array = sequence[i].neighbor_paths[sequence[i + 1]];
			acm += len(path)
		return acm;



func _on_world_map_settlement_hovered(settlement: Settlement) -> void:
	if settlement != Entities.player_party.current_settlement:
		highlight_travel(Entities.player_party.current_settlement, settlement)
