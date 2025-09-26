extends Camera2D

signal started_panning

var panning:bool = false;
var pan_speed:float = 10.0;

func _physics_process(_delta: float) -> void:
	var vector:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	if vector:
		if not panning:
			panning = true;
			started_panning.emit()
		position += vector * pan_speed
	elif panning:
		panning = false;
	
var zoom_moving:bool=false;
func _input(e:InputEvent)->void:
	if e.is_action_pressed("world_map_zoom_out") and zoom > Vector2(.25, .25) and not zoom_moving:
		zoom_moving = true;
		var tween:Tween = create_tween();
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(self, "zoom", zoom/2, 1)
		tween.finished.connect(zoom_move_finished);
		pan_speed *= 2;
	elif e.is_action_pressed("world_map_zoom_in") and zoom < Vector2(1, 1) and not zoom_moving:
		zoom_moving = true;
		var tween:Tween = create_tween();
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(self, "zoom", zoom*2, 1)
		tween.finished.connect(zoom_move_finished);
		pan_speed /= 2;
	
func zoom_move_finished()->void:
	zoom_moving =false;

var pan_to_player_tween:Tween;
func pan_to_player()->void:
	pan_to_player_tween = create_tween()
	pan_to_player_tween.tween_property(self, "position", Vector2.ZERO, 1);

func stop_pan_to_player()->void:
	if pan_to_player_tween and pan_to_player_tween.is_running():
		pan_to_player_tween.kill();
