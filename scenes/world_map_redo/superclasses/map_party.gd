extends Node2D

class_name MapParty;

signal started_moving;
signal stopped_moving;

signal settlement_visited(settlement:Settlement)
signal settlement_entered(settlement:Settlement);

## match this to the road tilemap directly one of these days
@onready var road_cell_size:int = Entities.road.tile_set.tile_size.x * Entities.road.scale.x;


@export var leader:Leader;
@export var vehicle:Vehicle;
@export var current_settlement:Settlement;

## right now measures:
## 1 block = 10km 
## on default speed (1) = 60 km/h = 1 block/10 minutes
@export var navigation_speed:float = 1;

var stops:Array[Settlement]
var current_path:Array;

var moving:bool = false;

var movement_origin:Settlement;
var movement_target:Settlement;
var next_cell:Vector2;

func _ready()->void:
	ColorCoder.color_code_vehicle(vehicle, leader);

func move_to_settlement(target:Settlement)->void:
	if target in current_settlement.neighbor_paths:
		stops = [];
		current_path = Array(current_settlement.neighbor_paths[target]);
		movement_target = target;
	else:

		stops = Entities.road.get_path_sequence(current_settlement, target);
		for stop:Settlement in stops:
			print(stop.name)
		current_path = Array(current_settlement.neighbor_paths[stops[1]]);
		movement_target = stops[1]
	
		
	movement_origin = current_settlement;
	current_settlement = null;
	moving = true;
	get_next_cell()
	started_moving.emit();

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

	
func _process(delta:float)->void:
	if moving:
		position = position.move_toward(next_cell, delta * 500 * navigation_speed)
		if position == next_cell:
			if position == movement_target.position:
				movement_origin = null;
				current_settlement = movement_target;
				settlement_visited.emit(movement_target)
				moving = false;
			else:
				get_next_cell()
		
