extends Camera2D

var in_player:bool = true;

const move_speed = 200;

func free_panning():
	position_smoothing_enabled = false
	reparent(Entities.world_map);
	in_player = false;

func return_to_player():
	if not in_player:
		in_player = true;
		var tween = create_tween();
		tween.tween_property(self, "position", Entities.in_map_player.position, .5);
		await tween.finished;
		reparent(Entities.in_map_player, true);
		global_position = Entities.in_map_player.global_position;
		
		
		
		
	

func _process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += direction * delta * move_speed;
