extends Sprite2D

class_name Vehicle

@export var party:MapParty;

func _ready()->void:
	ColorCoder.color_code_vehicle(self, party.leader);


func _on_bounce_timeout() -> void:
	if frame_coords.y:
		frame_coords.y = 0;
	else:
		frame_coords.y = 1;




func party_started_moving() -> void:
	flip_h = party.position.x > party.target_position.x;
	if party.position.y < party.target_position.y:
		frame_coords.x = 1;
	else:
		frame_coords.x = 0;
