extends Camera2D
class_name PlayerCamera;

@onready var player: PlayerFighter = get_parent()

enum TransformVFX{
	lunge, recoil, shake
}

var max_distance:int = range_max_distances[WeaponDisplay.CameraRange.short]
func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (mouse_position - player.global_position).normalized()
	var distance: float = player.global_position.distance_to(mouse_position)
	
	var distance_x:int = min(distance, max_distance * 2)
	var distance_y:int = min(distance, max_distance )
	global_position = player.global_position + direction * Vector2(distance_x, distance_y)


@onready var camera_tween:Tween=create_tween()
var current_magnitude:int = 0;

var animation_methods:Dictionary[TransformVFX, Callable] = {
	TransformVFX.lunge:lunge_feedback,
	TransformVFX.recoil:recoil_feedback,
	TransformVFX.shake:shake_feedback
}
func camera_vfx(vfx:TransformVFX, magnitude:int)->void:
	if camera_tween and camera_tween.is_running() and magnitude <= current_magnitude:
		return
	camera_tween.kill()
	current_magnitude = magnitude
	animation_methods[vfx].call(magnitude)


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
		var direction:Vector2 = Vector2(randf_range(-.1, .1), randf_range(-1., 1.))
		camera_tween.tween_callback(set_offset.bind(direction * shake_range))
		camera_tween.tween_interval(.05)
	
	camera_tween.tween_callback(set_offset.bind(Vector2.ZERO))

const range_max_distances:Dictionary[WeaponDisplay.CameraRange,int] = {
	WeaponDisplay.CameraRange.short:100,
	WeaponDisplay.CameraRange.long: 200
}
const range_smoothing_speeds:Dictionary[WeaponDisplay.CameraRange, int] = {
	WeaponDisplay.CameraRange.short:4,
	WeaponDisplay.CameraRange.long: 3.5
}

func _on_equipment_weapon_equipped(weapon: Weapon) -> void:
	max_distance = range_max_distances[weapon.display.camera_range]
	position_smoothing_speed = range_smoothing_speeds[weapon.display.camera_range]
