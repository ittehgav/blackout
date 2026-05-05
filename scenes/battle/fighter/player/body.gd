extends FighterBase
class_name PlayerFighterBase;

@export var player:PlayerFighter
## very ugly how this inherits fighterbase and has a ton of properties that do nothing
## and could lead to bugs as i expand on fighterbase

func full_skill_description(_unit:FighterUnit)->String:
	return "fsd?"

func _physics_process(_delta: float) -> void:
	var direction:Vector2;
	if not player.moving:
		direction = global_position.direction_to(get_global_mouse_position())
	else:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var angle:float = direction.angle()
	frame_coords.x =  player.get_sector(angle);
