extends Sprite2D

class_name Vehicle

@export var party:MapParty;

var wheel_bounce_acm:float = 0.0;

func _ready():
	party = get_parent();
	ColorCoder.color_code_vehicle(self);

func _physics_process(delta: float) -> void:
	

	var check_position:Vector2;
	if party.target_entity:
		check_position = party.target_entity.global_position;
	elif party.target_position != party.global_position:
		check_position = party.target_position;

	if check_position:
		wheel_bounce_acm += delta;
		if wheel_bounce_acm >= .5:
			wheel_bounce_acm = 0.0
			if frame_coords.y:
				frame_coords.y = 0;
			else:
				frame_coords.y = 1;
				
		flip_h = party.global_position.x > check_position.x;
		if check_position.y < party.global_position.y:
			frame_coords.x = 0;
		else:
			frame_coords.x = 1;
