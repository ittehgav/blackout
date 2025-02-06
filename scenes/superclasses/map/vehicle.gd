extends Sprite2D

class_name Vehicle

@export var party:MapParty;


func _physics_process(_delta: float) -> void:
	var check_position:Vector2;
	if party.target_entity:
		check_position = party.target_entity.global_position;
	elif party.target_position != party.global_position:
		check_position = party.target_position;

	if check_position:
		flip_h = party.global_position.x > check_position.x;
		if check_position.y > party.global_position.y:
			frame = 0;
		else:
			frame = 1;
