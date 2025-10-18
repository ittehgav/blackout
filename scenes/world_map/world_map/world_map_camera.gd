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

const min_zoom = Vector2(.25, .25);
const max_zoom = Vector2(2, 2)
var zoom_moving:bool=false;
func _input(e:InputEvent)->void:
	## HIGHER ZOOM = FARTHER
	## ZOOM IN = DECREASE SCALE
	## ZOOM OUT = INCREASE SCALE = CAMERA SMALLER
	if e.is_action_pressed("world_map_zoom_in") and zoom < max_zoom and not zoom_moving\
	and Entities.main.substate == "main":
		zoom_in()
	elif e.is_action_pressed("world_map_zoom_out") and zoom > min_zoom and not zoom_moving\
	and Entities.main.substate == "main":
		zoom_out()

func zoom_out(target_zoom:Vector2=zoom/2)->void:
	zoom_moving = true;
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "zoom", target_zoom, 1)
	tween.finished.connect(zoom_move_finished);


func zoom_in(target:Vector2=zoom*2)->void:
	zoom_moving = true;
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "zoom", target, 1)
	tween.finished.connect(zoom_move_finished);


func zoom_move_finished()->void:
	pan_speed = 10/zoom.x
	zoom_moving =false;

var pan_to_player_tween:Tween;
func pan_to_player()->void:
	pan_to_player_tween = create_tween()
	pan_to_player_tween.tween_property(self, "position", Vector2.ZERO, 1);
	if zoom < max_zoom:
		zoom_in(max_zoom)

func stop_pan_to_player()->void:
	if pan_to_player_tween and pan_to_player_tween.is_running():
		pan_to_player_tween.kill();
