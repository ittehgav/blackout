extends FighterBase
class_name PlayerFighterBase;

@export var player:PlayerFighter
## very ugly how this inherits fighterbase and has a ton of properties that do nothing
## and could lead to bugs as i expand on fighterbase

func full_skill_description(_unit:FighterUnit)->String:
	return "fsd?"

func _physics_process(_delta: float) -> void:
	var direction:Vector2 = global_position.direction_to(get_global_mouse_position())
	var angle:float = direction.angle()
	#if d.x < 0: d.x = -1.1;
	#if d.y < 0: d.y = -1.1;
	
	frame_coords.x =  player.get_sector(angle);
	if direction.dot(player.velocity) < 0 and animation_player.current_animation == "player/walk":
		animation_player.speed_scale = -1
	else:
		animation_player.speed_scale = 1;
	
	
