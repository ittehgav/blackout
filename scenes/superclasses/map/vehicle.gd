extends Sprite2D

class_name Vehicle

@export var party:MapParty;

func _ready()->void:
	await party.ready
	ColorCoder.color_code_vehicle(self, party.leader);


func _on_bounce_timeout() -> void:
	if frame_coords.y:
		frame_coords.y = 0;
	else:
		frame_coords.y = 1;


func adjust_direction(target_position:Vector2)->void:
	flip_h =  target_position.x < global_position.x;
	if global_position.y < target_position.y:
		frame_coords.x = 1
	else:
		frame_coords.x = 0;


func party_started_moving() -> void:
	var target_position:Vector2;
	if party.target_entity:
		target_position = party.target_entity.global_position;
	else:
		target_position = party.target_position
	flip_h = global_position.x > target_position.x;
	if global_position.y < target_position.y:
		frame_coords.x = 1;
	else:
		frame_coords.x = 0;
