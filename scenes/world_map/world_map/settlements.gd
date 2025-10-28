extends Node2D

const spawn_range = 10000

const total_settlements = 40;

@export var all_location_scenes:Array[PackedScene];

var building_pool:Array[Building];
var dungeon_pool:Array[Dungeon]
const dungeon_rate = .3

@export var road:RoadGrid;
@export var fog:TileMapLayer



func _ready()->void:
	generate_settlements();


func generate_settlements()->void:
	for scene:PackedScene in all_location_scenes:
		var location:Location = scene.instantiate();
		if location is Building:
			building_pool.append(location);
		elif location is Dungeon:
			dungeon_pool.append(location)
	
	var all_settlements:Array[Settlement] = [Entities.player_party.current_settlement]
	
	for i:int in total_settlements:
		var settlement:Settlement = Index.scenes.settlement.instantiate();
		
		var x_roll:int = randi_range(-spawn_range, spawn_range)
		var y_roll:int = randi_range(-spawn_range, spawn_range);
		var roll:Vector2 = Vector2(x_roll, y_roll)
		
		while not check_position_clear(roll, all_settlements):
			x_roll = randi_range(-spawn_range, spawn_range)
			y_roll = randi_range(-spawn_range, spawn_range);
			roll = Vector2(x_roll, y_roll)
		
		settlement.position = roll
		all_settlements.append(settlement);
		
		var type_roll:float = randf_range(0.0, 1.0);
		var type:String = "regular";
		if type_roll < dungeon_rate:
			type = "dungeon"
		populate_settlement(settlement, type)
		
		
		add_child(settlement)
	
	for settlement:Settlement in all_settlements:
		assign_neighbors(settlement, all_settlements);
	
	road.generate_roads(all_settlements);
	fog.refresh_fog()

func populate_settlement(settlement:Settlement, type:String)->void:
	## TODO make it so this makes an even-ish spread of the buildings?
	var current_locations:Array[String]
	while space_taken(settlement) < 3:
		## rigth now all dungeons are size 3 so there's no chance of overlap
		var location:Location;
		if type == "dungeon":
			location = dungeon_pool.pick_random();
		else:
			location = building_pool.pick_random()
		if location.name not in current_locations and location.size + space_taken(settlement) <=3:
			var b:Location = location.duplicate()

			settlement.locations.append(b);
			current_locations.append(location.name)
			settlement.add_child(b)

	
func space_taken(settlement:Settlement)->int:
	var total:int = 0;
	for b:Location in settlement.locations:
		total += b.size;
	return total

func check_position_clear(roll:Vector2, all_settlements:Array[Settlement])->bool:
	for s:Settlement in all_settlements:
		if roll.distance_to(s.position) < 100:
			return false;
	return true

func assign_neighbors(target:Settlement, all_settlements:Array[Settlement])->void:
	var distances:Array[float]
	for settlement:Settlement in all_settlements:
		if settlement != target:
			var distance:float = target.position.distance_to(settlement.position)
			if len(target.neighbors) < 3:
				target.neighbors.append(settlement);
				
				if len(target.neighbors) == 3:
					target.neighbors.sort_custom(neighbor_distance_sort.bind(target));
					for neighbor:Settlement in target.neighbors:
						## already sorted by the neighbors sort
						distances.append(target.position.distance_to(neighbor.position));
				
			else:
				if distance < distances[2]:
					distances.remove_at(2)
					target.neighbors.remove_at(2);
					if distance > distances[1]:
						target.neighbors.append(settlement);
						distances.append(distance)
					elif distance > distances[0]:
						target.neighbors.insert(1, settlement);
						distances.insert(1, distance);
					else:
						target.neighbors.insert(0, settlement);
						distances.insert(0, distance);

func neighbor_distance_sort(a:Settlement, b:Settlement, target:Settlement)->bool:
	return target.position.distance_to(a.position) < target.position.distance_to(b.position);
