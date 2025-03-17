extends CanvasModulate

@export var cycle_colors:Array[Color] = [
	Color(0.04, 0.04, 0.12),       # Midnight (dark blue)
	Color(0.08, 0.08, 0.20),       # Early night (slightly lighter blue)
	Color(0.12, 0.12, 0.27),       # Late night (medium blue)
	Color(0.20, 0.20, 0.39),       # Pre-dawn (lighter blue)
	Color(0.39, 0.31, 0.47),       # Dawn (purple-ish)
	Color(0.59, 0.39, 0.55),       # Early morning (pink-ish)
	Color(1.00, 0.78, 0.59),       # Sunrise (warm orange)
	Color(1.00, 1.00, 0.78),       # Morning (light yellow)
	Color(0.78, 0.90, 1.00),       # Midday (bright sky blue)
	Color(0.59, 0.78, 1.00),       # Afternoon (lighter sky blue)
	Color(0.39, 0.59, 0.78),       # Evening (dusk blue)
	Color(0.20, 0.39, 0.59)        # Late evening (darkening blue)

]
func _ready():
	await get_parent().ready
	update_lighting()


func update_lighting()->void:
	var index:int = Entities.world_map.current_hour;
	if index > 11:
		index -= 11
		index = 12 - index
	var tween:Tween = create_tween();
	tween.tween_property(self, "color", cycle_colors[index], 1);

func _input(e:InputEvent)->void:
	if e.is_action_pressed("move_right"):
		get_tree().paused = false;
