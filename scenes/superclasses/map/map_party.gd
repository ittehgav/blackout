extends MapEntity

class_name MapParty

@warning_ignore("unused_signal")
signal started_moving;
@warning_ignore("unused_signal")
signal stopped_moving;


@export var leader:Leader;
@export var vehicle:Vehicle

var target_entity:MapEntity;
var target_position:Vector2;
