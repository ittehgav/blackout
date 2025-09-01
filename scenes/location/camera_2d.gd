extends Camera2D

@export var screen_blink:ColorRect;

# The maximum distance the camera can move from its parent
@export var max_distance_from_parent: float = 100.0

# Reference to the parent node (e.g., the player)
@onready var parent: Node2D = get_parent()
func _ready()->void:
	Entities.current_camera = self;

func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (mouse_position - parent.global_position).normalized()	
	var distance: float = parent.global_position.distance_to(mouse_position)
	
	distance = min(distance, max_distance_from_parent)
	global_position = parent.global_position + direction * distance
