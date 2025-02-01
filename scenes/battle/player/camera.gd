extends Camera2D

# The maximum distance the camera can move from its parent
@export var max_distance_from_parent: float = 100.0

# Reference to the parent node (e.g., the player)
@onready var parent: Node2D = get_parent()

func _process(delta: float) -> void:
	# Get the global position of the mouse cursor
	var mouse_position: Vector2 = get_global_mouse_position()
	
	# Calculate the direction from the parent to the mouse cursor
	var direction: Vector2 = (mouse_position - parent.global_position).normalized()
	
	# Calculate the distance from the parent to the mouse cursor
	var distance: float = parent.global_position.distance_to(mouse_position)
	
	# Clamp the distance to the maximum allowed distance
	distance = min(distance, max_distance_from_parent)
	
	# Set the camera's position to the parent's position plus the offset
	global_position = parent.global_position + direction * distance
