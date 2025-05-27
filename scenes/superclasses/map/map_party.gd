extends MapEntity

class_name MapParty

signal quadrant_changed(new_quadrant:WorldMapQuadrant, direction:Vector2);

signal entity_entered_range(entity:MapEntity);
signal entity_left_range(entity:MapEntity);

signal started_moving;
signal stopped_moving;


@export var leader:Leader;
@export var vehicle:Vehicle

var target_entity:MapEntity;
var target_position:Vector2=Vector2.ZERO;

## navigation is the more fixed value that will determine move speed
## right now player move speed drops due to fuel shortages
@export var navigation:int=3;
@onready var move_speed:float = navigation * 50;

@onready var current_quadrant:WorldMapQuadrant = get_parent();

func _on_quadrant_changed(new_quadrant: WorldMapQuadrant, direction: Vector2) -> void:
	current_quadrant = new_quadrant;
