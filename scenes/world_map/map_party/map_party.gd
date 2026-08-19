@abstract
extends Node2D


class_name MapParty;

signal started_moving;
signal stopped_moving;




signal location_visited(location:Location)
signal location_entered(location:Location);

const road_cell_size = 64;

@export var leader:Leader;
@export var vehicle:Vehicle;
@export var current_location:Location;

## NAVIGATION SPEED = ROAD CELLS/IGT H
@export var navigation_speed:float = 60.0;

@onready var world_map:WorldMap = get_tree().get_first_node_in_group("world_map")

var irl_cell_travel_time:float;

var stops:Array[Location]
var current_path:Array;


var movement_target:Location;
var next_cell:Vector2;

func _ready()->void:
	refresh_speed();
	
func refresh_speed()->void:
	if leader.inventory.fuel:
		navigation_speed = 60;
		
	irl_cell_travel_time = 3600/(navigation_speed*Index.irl_time_scale)




func move_to_location(target:Location)->void:
	if target in current_location.neighbor_paths:
		stops = [];
		current_path = Array(current_location.neighbor_paths[target]);
		movement_target = target;
	else:
		stops = Entities.road.get_path_sequence(current_location, target);
		current_path = Array(current_location.neighbor_paths[stops[1]]);
		movement_target = stops[1]
	navigation_tween = create_tween();
	
	start_navigation_tween()
	current_location = null;
	started_moving.emit();

@onready var navigation_tween:Tween = create_tween();
func start_navigation_tween()->void:
	## using tweens is easier than process to get consistent movement timing
	while len(current_path) > 0:
		get_next_cell();
		navigation_tween.tween_property(self, "global_position", next_cell, irl_cell_travel_time)
	navigation_tween.tween_callback(navigation_finished)
	
func navigation_finished()->void:
	visit_location(movement_target)




func get_next_cell()->void:
	var previous_cell:Vector2 = next_cell;
	next_cell = current_path.pop_front() * road_cell_size;
	var direction:Vector2i = next_cell - previous_cell
	var direction_vector:Vector2i;
	if direction.x > 0:
		direction_vector = Vector2i.RIGHT
	elif direction.x < 0:
		direction_vector = Vector2i.LEFT
	elif direction.y < 0:
		direction_vector = Vector2i.UP
	elif direction.y > 0:
		direction_vector = Vector2i.DOWN;
	navigation_tween.tween_callback(vehicle.adjust_direction.bind(direction_vector))


func get_travel_minutes(target:Location)->int:
	var cell_distance:int = Entities.road.get_location_distance(current_location, target);
	var final_minutes:int = (cell_distance*60) /navigation_speed
	return final_minutes


func visit_location(target:Location = current_location)->void:
	current_location = target;
	current_location.data.visited = true;
	
	location_visited.emit(target)
	target.player_visited.emit()

@abstract func enter_location()->void;
