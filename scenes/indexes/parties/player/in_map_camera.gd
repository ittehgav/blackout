extends Camera2D

var in_player:bool = true;

const move_speed = 200;

func free_panning()->void:
	position_smoothing_enabled = false
	reparent(Entities.world_map);
	in_player = false;

func return_to_player()->void:
	if not in_player:
		in_player = true;
		var tween:Tween = create_tween();
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(self, "position", Entities.in_map_player.position, .25);
		await tween.finished;
		reparent(Entities.in_map_player, true);
		global_position = Entities.in_map_player.global_position;


func _process(delta: float) -> void:
	var direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += direction * delta * move_speed;
	
func pan_to_target(target:MapEntity)->void:
	free_panning()
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", target.global_position, 2);
