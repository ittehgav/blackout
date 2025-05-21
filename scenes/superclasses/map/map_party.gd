extends MapEntity

class_name MapParty

signal entity_entered_range(entity:MapEntity);
signal entity_left_range(entity:MapEntity);

signal started_moving;
signal stopped_moving;


@export var leader:Leader;
@export var vehicle:Vehicle

var target_entity:MapEntity;
var target_position:Vector2=Vector2.ZERO;

@export var move_speed:float = 200.0;

@onready var current_quadrant:WorldMapQuadrant = get_parent();
