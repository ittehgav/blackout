extends Node2D


var building_pool:Array[Building];
var dungeon_pool:Array[Dungeon]
const dungeon_rate = .3

@export var road:RoadGrid;
@export var fog:TileMapLayer

var all_locations:Array[Location]

func _ready()->void:
	for c:Node in get_children():
		if c is Location:
			all_locations.append(c);

	for l:Location in all_locations:
		assign_neighbors(l)
	
	road.generate_roads(all_locations);
	## just does nothing when loading previous session?
	## which we can't even do rn
	fog.reveal_neighbors();
	

func generate_locations()->void:
	pass
	## TODO redo this
	## still get generation but it's easier to do over 
	## with the new class order than to try and salvage this
	#for scene:PackedScene in all_building_scenes:
		#var location:Settlement = scene.instantiate();
		#if location is Building:
			#building_pool.append(location);
		#elif location is Dungeon:
			#dungeon_pool.append(location)
	#
	#var all_settlements:Array[Location] = [Entities.player_party.current_settlement]
	#
	#for i:int in total_settlements:
		#var settlement:Location = Index.scenes.settlement.instantiate();
		#
		#var x_roll:int = randi_range(-spawn_range, spawn_range)
		#var y_roll:int = randi_range(-spawn_range, spawn_range);
		#var roll:Vector2 = Vector2(x_roll, y_roll)
		#
		#while not check_position_clear(roll, all_settlements):
			#x_roll = randi_range(-spawn_range, spawn_range)
			#y_roll = randi_range(-spawn_range, spawn_range);
			#roll = Vector2(x_roll, y_roll)
		#
		#settlement.position = roll
		#all_settlements.append(settlement);
		#
		#var type_roll:float = randf_range(0.0, 1.0);
		#var type:String = "regular";
		#if type_roll < dungeon_rate:
			#type = "dungeon"
		#populate_settlement(settlement, type)
		#
		#
		#add_child(settlement)
	
	

func populate_location(_location:Location, _type:String)->void:
	pass
	## TODO make it so this makes an even-ish spread of the settlements?
	## TODO POPULATE_LOCATION = fill it with settlements
	#var current_locations:Array[String]
	#while space_taken(settlement) < 3:
		### rigth now all dungeons are size 3 so there's no chance of overlap
		#var location:Settlement;
		#if type == "dungeon":
			#location = dungeon_pool.pick_random();
		#else:
			#location = building_pool.pick_random()
		#if location.name not in current_locations and location.size + space_taken(settlement) <=3:
			#var b:Settlement = location.duplicate()
#
			#settlement.settlements.append(b);
			#current_locations.append(location.name)
			#settlement.add_child(b)

	
func space_taken(location:Location)->int:
	var total:int = 0;
	for b:Settlement in location.settlements:
		total += b.size;
	return total

func check_position_clear(roll:Vector2, all_locations:Array[Location])->bool:
	for s:Location in all_locations:
		if roll.distance_to(s.position) < 100:
			return false;
	return true

func assign_neighbors(target:Location)->void:
	var distances:Array[float]
	for location:Location in all_locations:
		if location != target:
			var distance:float = target.position.distance_to(location.position)
			if len(target.neighbors) < 3:
				target.neighbors.append(location);
				
				if len(target.neighbors) == 3:
					target.neighbors.sort_custom(neighbor_distance_sort.bind(target));
					for neighbor:Location in target.neighbors:
						## already sorted by the neighbors sort
						distances.append(target.position.distance_to(neighbor.position));
				
			else:
				if distance < distances[2]:
					distances.remove_at(2)
					target.neighbors.remove_at(2);
					if distance > distances[1]:
						target.neighbors.append(location);
						distances.append(distance)
					elif distance > distances[0]:
						target.neighbors.insert(1, location);
						distances.insert(1, distance);
					else:
						target.neighbors.insert(0, location);
						distances.insert(0, distance);

func neighbor_distance_sort(a:Location, b:Location, target:Location)->bool:
	return target.position.distance_to(a.position) < target.position.distance_to(b.position);
