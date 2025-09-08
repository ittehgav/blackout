extends Node2D

class_name MapParty;

signal started_moving;
signal stopped_moving;

signal settlement_visited(settlement:Settlement)
signal settlement_entered(settlement:Settlement);

## match this to the road tilemap directly one of these days
@export var status:MapPartyStatus;

const road_cell_size = 32;

@export var leader:Leader;
@export var vehicle:Vehicle;
@export var current_settlement:Settlement;

## NAVIGATION SPEED = ROAD CELLS/IGT H
@export var navigation_speed:float = 60.0;
var irl_cell_travel_time:float;

var stops:Array[Settlement]
var current_path:Array;


var movement_target:Settlement;
var next_cell:Vector2;

func _ready()->void:
	ColorCoder.color_code_vehicle(vehicle, leader);
	refresh_speed();
	
func refresh_speed()->void:
	irl_cell_travel_time = 3600/(navigation_speed*Index.irl_time_scale)



func move_to_settlement(target:Settlement)->void:
	if target in current_settlement.neighbor_paths:
		stops = [];
		current_path = Array(current_settlement.neighbor_paths[target]);
		movement_target = target;
	else:
		stops = Entities.road.get_path_sequence(current_settlement, target);
		current_path = Array(current_settlement.neighbor_paths[stops[1]]);
		movement_target = stops[1]
	navigation_tween = create_tween();
	
	start_navigation_tween()
	current_settlement = null;
	started_moving.emit();

@onready var navigation_tween:Tween = create_tween();
func start_navigation_tween()->void:
	## using tweens is easier than process to get consistent movement timing
	while len(current_path) > 0:
		get_next_cell();
		navigation_tween.tween_property(self, "global_position", next_cell, irl_cell_travel_time)
	navigation_tween.tween_callback(finish_navigation_tween)
	
func finish_navigation_tween()->void:
	current_settlement = movement_target;
	settlement_visited.emit(movement_target)
	return;

func get_next_cell()->void:
	next_cell = current_path.pop_front() * road_cell_size;
	var direction:Vector2i = next_cell - position
	var direction_vector:Vector2i;
	
	if direction.x > 0:
		direction_vector = Vector2i.RIGHT
	elif direction.x < 0:
		direction_vector = Vector2i.LEFT
	elif direction.y < 0:
		direction_vector = Vector2i.UP
	else:
		direction_vector = Vector2i.DOWN;
	if vehicle.current_direction != direction_vector:
		vehicle.adjust_direction(direction_vector)


func get_travel_minutes(target:Settlement)->int:
	## BUG THIS UNDERESTIMATES IN A WAY WHERE THE LONGER THE DISTANCE, THE MORE IT UNDERSHOOTS
	var cell_distance:int = Entities.road.get_settlement_distance(current_settlement, target);
	var final_minutes:int = (cell_distance*60) /navigation_speed
	return final_minutes
