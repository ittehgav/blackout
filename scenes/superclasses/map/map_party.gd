extends MapEntity

class_name MapParty

signal started_moving;
signal stopped_moving;


@export var leader:Leader;
@export var vehicle:Vehicle

var target_entity:MapEntity;
var target_position:Vector2;
