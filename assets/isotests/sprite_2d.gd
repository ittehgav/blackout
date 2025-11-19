extends Sprite2D

signal started_moving;
signal stopped_moving;
signal angle_changed;

@export var anchor:Node2D;

var moving:bool=false;
@export var shadow:Sprite2D
@export var animation_player:AnimationPlayer

const angle_indexes:Dictionary[Vector2, int] = {
	Vector2.UP:0,
	Vector2(1, -1):1,
	Vector2(1, 0):2,
	Vector2(1, 1):3,
	Vector2(0, 1):4,
	Vector2(-1, 1):5,
	Vector2(-1, 0):6,
	Vector2(-1, -1):7
}

var movement:Vector2;


func _process(delta:float)->void:
	var x:int;
	var y:int;
	if Input.is_key_pressed(KEY_W):
		y = - 1;
	elif Input.is_key_pressed(KEY_S):
		y = 1;
	if Input.is_key_pressed(KEY_A):
		x = -1;
	elif Input.is_key_pressed(KEY_D):
		x = 1;
	movement = Vector2(x, y)
	if movement != Vector2.ZERO:
		if not moving:
			moving = true;
			started_moving.emit();
		anchor.position += movement 
	else:
		if moving:
			moving = false;
			stopped_moving.emit()

func _input(e:InputEvent)->void:
	if e is InputEventMouseMotion:
		face_cursor()
	if Input.is_action_just_pressed("use_weapon"):
		attack_animation();

func face_cursor()->void:
	var angle:Vector2 = global_position.direction_to(get_global_mouse_position())
	var target_i:int = angle_indexes[angle.snapped(Vector2.ONE)]
	if frame_coords.x != target_i:
		frame_coords.x = target_i;
		shadow.rotation = angle_indexes.find_key(frame_coords.x).angle() + PI/2
		angle_changed.emit()
	

func attack_animation()->void:
	var tween:Tween = create_tween();
	var angle:Vector2 = angle_indexes.find_key(frame_coords.x)
	offset = angle * 30
	shadow.position = angle * 60
	tween.tween_property(self, "offset", Vector2.ZERO, .25);
	tween.parallel().tween_property(shadow, "position", Vector2(0, 0), .25);
	frame_coords.y = 1;
	tween.tween_callback(reset_frame_y)

@onready var shadow_origin:Vector2 = shadow.position
func reset_frame_y()->void:

	frame_coords.y = 0;
	shadow.position = shadow_origin




func adjust_playback() -> void:
	var movement_v2:Vector2 = movement
	var cursor_v2:Vector2 = get_global_mouse_position() - global_position
	if sign(movement_v2.x) != sign(cursor_v2.x) and sign(movement_v2.y) != sign(cursor_v2.y):
		animation_player.speed_scale = -1.5;
	else:
		animation_player.speed_scale = 1.5


func _on_stopped_moving() -> void:
	position = Vector2.ZERO
	reset_frame_y()
