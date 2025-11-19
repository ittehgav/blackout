extends Sprite2D

signal started_moving;
signal stopped_moving;

@export var animation_player:AnimationPlayer

var moving:bool=false;

@export var cooldown_timer:Timer;
@export var retry_timer:Timer;

@export var target:Node2D;
@onready var anchor:Node2D = get_parent()

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

func target_in_range()->bool:
	return anchor.position.distance_to(target.position) <= 50;

func _physics_process(delta: float) -> void:
	if anchor.position.distance_to(target.position) > 50:
		if not moving:
			moving = true;
			started_moving.emit()
		anchor.position = anchor.position.move_toward(target.position, delta * 50);
		face_target();
	else:
		if moving:
			moving = false;
			stopped_moving.emit()

func face_target()->void:
	var angle:Vector2 = anchor.position.direction_to(target.position);
	var target_i:int = angle_indexes[angle.snapped(Vector2.ONE)]
	if frame_coords.x != target_i:
		frame_coords.x = target_i;


func try_skill() -> void:
	if target_in_range():
		use_skill()
		cooldown_timer.start();
		retry_timer.stop()
	else:
		retry_timer.start()


func use_skill()->void:
	animation_player.play("skill")
	await animation_player.animation_finished;
	dash();

func dash()->void:
	var tween:Tween = create_tween();
	var dash_shift:Vector2 = angle_indexes.find_key(frame_coords.x) * 30
	position = dash_shift
	tween.tween_property(self, "position", Vector2.ZERO, .75)
	await tween.finished;
	frame_coords.y = 0;
