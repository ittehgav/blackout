extends Camera2D


# The maximum distance the camera can move from its parent

# Reference to the parent node (e.g., the player)
@onready var parent: Node2D = get_parent()

const max_distance:int = 100
func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (mouse_position - parent.global_position).normalized()	
	var distance: float = parent.global_position.distance_to(mouse_position)
	
	distance = min(distance, max_distance)
	global_position = parent.global_position + direction * distance
