extends TextureRect

var rps:float = 1.5;

func _physics_process(delta: float) -> void:
	rotation_degrees += rps*delta* 360
