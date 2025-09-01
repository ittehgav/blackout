extends Node2D

class_name MapParty;

signal started_moving;
signal stopped_moving;

signal settlement_visited(settlement:Settlement)
signal settlement_entered(settlement:Settlement);

## match this to the road tilemap directly one of these days
@export var status:MapPartyStatus;

@onready var road_cell_size:int = Entities.road.tile_set.tile_size.x * Entities.road.scale.x;


@export var leader:Leader;
@export var vehicle:Vehicle;
@export var current_settlement:Settlement;

## NAVIGATION SPEED = KM/H
@export var navigation_speed:float = 60;
var km_per_second:float;

var stops:Array[Settlement]
var current_path:Array;


var movement_target:Settlement;
var next_cell:Vector2;

func _ready()->void:
	ColorCoder.color_code_vehicle(vehicle, leader);
	refresh_speed();

func refresh_speed()->void:
	km_per_second  = (navigation_speed/3600) * Index.irl_time_scale


func move_to_settlement(target:Settlement)->void:
	if target in current_settlement.neighbor_paths:
		stops = [];
		current_path = Array(current_settlement.neighbor_paths[target]);
		movement_target = target;
	else:
		stops = Entities.road.get_path_sequence(current_settlement, target);
		current_path = Array(current_settlement.neighbor_paths[stops[1]]);
		movement_target = stops[1]

	navigation_loop(true)
	current_settlement = null;
	get_next_cell()
	started_moving.emit();


func navigation_loop(first:bool=false)->void:
	print("mloo´p?")
	## using tweens is easier than process to get consistent movement timing
	if len(current_path) == 1 and not first:
		current_settlement = movement_target;
		settlement_visited.emit(movement_target)
		return;
	get_next_cell();
	var tween:Tween=create_tween();
	## 2 * km per second because the space between 2 cells = 2km
	tween.tween_property(self, "global_position", next_cell, 2/km_per_second)
	tween.tween_callback(navigation_loop)

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

	


		
