extends "res://scenes/world_map/world_map/tilemaps/road_gen.gd"

class_name RoadGrid;

func highlight_travel(l1:Location, l2:Location)->void:
	if l2 in l1.neighbor_paths:
		highlight_path(l1, l2)
	else:
		var stops:Array[Location] = get_path_sequence(l1, l2);
		for i:int in len(stops):
			highlight_path(stops[i], stops[i + 1]);


func highlight_path(l1:Location, l2:Location)->void:
	assert(l2 in l1.neighbor_paths and l1 in l2.neighbor_paths)
	var path:PackedVector2Array = l1.neighbor_paths[l2];
	highlight_tiles.highlight_path(path)


func get_path_sequence(l1:Location, l2:Location)->Array[Location]:
	var queue:Array[Location];
	var visited:Array[Location];
	var parent:Dictionary;
	
	queue.append(l1);
	visited.append(l1);
	parent[l1] = null;
	
	while len(queue):
		var current:Location = queue.pop_front()
		
		if current == l2:
			var path:Array[Location];
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


func get_location_distance(s1:Location, s2:Location)->int:
	if s2 in s1.neighbor_paths:
		## not sure why i need the + 1
		return len(s1.neighbor_paths[s2]);
	else:
		var acm:int = 0; 
		var sequence:Array[Location] = get_path_sequence(s1, s2);
		
		for i:int in len(sequence) - 1:
			var path:Array = sequence[i].neighbor_paths[sequence[i + 1]];
			acm += len(path)
		return acm;


func _on_world_map_location_hovered(location: Location) -> void:
	var current:Location = Entities.player_party.current_location
	if current and location != current:
		highlight_travel(Entities.player_party.current_location, location)
