extends Camera2D

signal started_panning

var panning:bool = false;
var pan_speed:float = 10.0;

var dragging_camera:bool=false;

func _ready()->void:
	State.substate_changed.connect(on_substate_changed);

func on_substate_changed(new:State.Substate, _old:State.Substate)->void:
	set_process_input(new == State.Substate.main);

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset_camera"):
		return_to_player();
	
	if Input.is_action_just_pressed("start_camera_drag"):
		dragging_camera = true;
	elif Input.is_action_just_released("start_camera_drag"):
		dragging_camera = false
		## TODO make the drag persist a little
		## the way below behaves weirdly
		#var tween:Tween = create_tween();
		#tween.tween_property(self, "position", position - drag_velocity/2, .3)


func return_to_player()->void:
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "position", Vector2.ZERO, 1);
	


const min_zoom = Vector2(.25, .25);
const max_zoom = Vector2(1, 1)
var zoom_moving:bool=false;
func _input(e:InputEvent)->void:
	## HIGHER ZOOM = FARTHER
	## ZOOM IN = DECREASE SCALE = EVERYTHING WITHIN CAMERA BIGGER
	## ZOOM OUT = INCREASE SCALE = EVERYTHING WITHIN CAMERA SMALLER
	if e.is_action_pressed("world_map_zoom_in") and zoom < max_zoom and not zoom_moving\
	and State.current_substate == State.Substate.main:
		zoom_in()
	elif e.is_action_pressed("world_map_zoom_out") and zoom > min_zoom and not zoom_moving\
	and State.current_substate == State.Substate.main:
		zoom_out()
	if dragging_camera and e is InputEventMouseMotion:
		position += e.relative * -2



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
	if zoom < max_zoom/2:
		zoom_in(max_zoom/2)

func stop_pan_to_player()->void:
	if pan_to_player_tween and pan_to_player_tween.is_running():
		pan_to_player_tween.kill();
