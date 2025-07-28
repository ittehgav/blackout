extends MapParty



signal quadrant_changed(new_quadrant:WorldMapQuadrant, direction:Vector2);

signal entity_entered_range(entity:MapEntity);
signal entity_left_range(entity:MapEntity);

signal started_moving;
signal stopped_moving;


@export var leader:Leader;
@export var vehicle:Vehicle

var statuses:Array[Dictionary];

var target_entity:MapEntity;
var target_position:Vector2=Vector2.ZERO;

## navigation is the more fixed value that will determine move speed
## right now player move speed drops due to fuel shortages
@export var navigation:int=3;
@onready var move_speed:float = navigation * 50;

@onready var current_quadrant:WorldMapQuadrant = get_parent();

func _ready()->void:
	ColorCoder.color_code_vehicle(vehicle, leader)
	vehicle.party = self;
	started_moving.connect(vehicle.adjust_direction);

func _on_quadrant_changed(new_quadrant: WorldMapQuadrant, _direction: Vector2) -> void:
	current_quadrant = new_quadrant;

func apply_party_status(type:String, duration_hours:int, removal_fn:Callable)->void:
	var status:Dictionary = {
		"type":type,
		"time_left":duration_hours, 
		"removal":removal_fn
	};
	Entities.world_map.hour_passed.connect(tick_down_status.bind(status));
	statuses.append(status);

func tick_down_status(status:Dictionary)->void:
	status.time_left -= 1
	if not status.time_left:
		status.removal_fn.call();
	Entities.world_map.hour_passed.disconnect(tick_down_status.bind(status));
	statuses.erase(status);
