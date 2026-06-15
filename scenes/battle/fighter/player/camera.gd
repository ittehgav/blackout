extends Camera2D
class_name PlayerCamera;

@onready var player: PlayerFighter = get_parent()

const max_distance:int = 100
func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (mouse_position - player.global_position).normalized()
	var distance: float = player.global_position.distance_to(mouse_position)
	
	distance = min(distance, max_distance)
	global_position = player.global_position + direction * distance


@onready var camera_tween:Tween=create_tween()
var current_magnitude:int = 0;

var animation_methods:Dictionary[String, Callable] = {
	"lunge":lunge_feedback,
	"recoil":recoil_feedback,
	"shake":shake_feedback
}
func camera_vfx(key:String, magnitude:int)->void:
	if camera_tween and camera_tween.is_running() and magnitude <= current_magnitude:
		return
	camera_tween.kill()
	current_magnitude = magnitude
	animation_methods[key].call(magnitude)


func lunge_feedback(magnitude:int)->Tween:
	var shift:Vector2 = position.move_toward(get_local_mouse_position(), .5);
	offset = shift * magnitude
	
	camera_tween = create_tween();
	camera_tween.tween_property(self, "offset", Vector2.ZERO, .1);
	return camera_tween;

func recoil_feedback(magnitude:int)->Tween:
	var shift:Vector2 = position.move_toward(get_local_mouse_position(), .5);
	offset = shift * -1 * magnitude
	camera_tween = create_tween();
	camera_tween.tween_property(self, "offset", Vector2.ZERO, .1 + (magnitude/2));
	return camera_tween;

func shake_feedback(magnitude:int)->void:
	camera_tween = create_tween();
	var shake_range:int = 30 * magnitude
	for i in range(5):
		var direction:Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, -1))
		camera_tween.tween_callback(set_offset.bind(direction * shake_range))
		camera_tween.tween_interval(.05)
	
	camera_tween.tween_callback(set_offset.bind(Vector2.ZERO))
