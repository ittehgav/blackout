extends Node2D

class_name WorldMap

signal hour_passed;
signal day_passed;

signal settlement_hovered(settlement:Settlement);
signal settlement_mouse_exited;

@export var sky_colors:Array[Color]

@export var origin:Settlement;
@export var road_tiles:TileMapLayer;

@export var settlements:Node2D;

## y3k?
@export var current_year:int = 3000;
@export_range(1, 12) var current_month:int
@export_range(1, 31) var current_day : int; 
@export_range(0, 23) var current_hour:int
@export_range(0, 59) var current_minute:int;

func _ready()->void:
	## TODO move this declaration for the moment the world map is instantiated
	Entities.world_map = self;
	get_tree().paused = true;
	
	var all_settlements:Array[Node] = settlements.get_children();
	for settlement:Settlement in all_settlements:
		assign_neighbors(settlement, all_settlements);
	road_tiles.generate_roads(all_settlements)

	
func assign_neighbors(target:Settlement, all_settlements:Array[Node])->void:
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


func _on_minute_ticker_timeout() -> void:
	current_minute += 1;
	if current_minute == 60:
		current_minute = 0;
		advance_hour();

func advance_hour()->void:
	hour_passed.emit();
	current_hour += 1;
	if current_hour == 24:
		current_hour = 0;
		advance_day()

func advance_day()->void:
	day_passed.emit()
	current_day += 1;
	if current_day == 32:
		advance_month();
		current_day = 0;

func advance_month()->void:
	current_month += 1;
	if current_month == 13:
		advance_year();

func advance_year()->void:
	current_year += 1;


func _on_enter_pressed() -> void:
	enter_settlement();
	
func enter_settlement(target:Settlement = Entities.player_party.current_settlement)->void:
	## TODO add loading screen when this starts to run from the main scene tree
	var location:Location = Index.scenes.location.instantiate();
	location.load_settlement(target)
	#location.tree_entered.connect(Entities.loading_screen.fade_out, CONNECT_ONE_SHOT);
	#await Entities.loading_screen.fade_in.finished;
	var parent:Node = get_parent();
	get_parent().remove_child(self);
	parent.add_child(location)
	
