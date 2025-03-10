extends CanvasModulate

var current_hour:int=0;
var current_minute:int=0;
const alpha = .8
const sand_color = Color.SANDY_BROWN;

@export var clock:Label;

@export var cycle_colors:Array[Color] = [
	Color(0.400, 0.378, 0.349, alpha),   # Pre-dawn on sand
	Color(0.518, 0.427, 0.447, alpha),   # Early dawn on sand
	Color(0.880, 0.545, 0.349, alpha),   # Sunrise on sand
	Color(0.645, 0.753, 0.712, alpha),   # Morning on sand
	Color(0.380, 0.723, 0.751, alpha),   # Midday on sand
	Color(0.576, 0.641, 0.715, alpha),   # Afternoon on sand
	Color(0.720, 0.772, 0.702, alpha),   # Late afternoon on sand
	Color(0.880, 0.484, 0.251, alpha),   # Sunset on sand
	Color(0.631, 0.349, 0.502, alpha),   # Twilight on sand
	Color(0.429, 0.398, 0.470, alpha),   # Dusk on sand
	Color(0.380, 0.349, 0.329, alpha),   # Night on sand
	Color(0.390, 0.359, 0.280, alpha)    # Late night on sand
]

func _ready():
	## will load with current time
	update_lighting();


func hour_passed() -> void:
	current_hour += 1;
	if current_hour == 24:
		current_hour = 0;
	update_lighting();
	
func update_lighting():
	if not current_hour % 2:
		var index = current_hour/2;
		var tween = create_tween();
		tween.tween_property(self, "color", cycle_colors[index], 1);


func _on_minute_ticker_timeout() -> void:
	current_minute += 1;
	if current_minute == 60:
		current_minute = 0;
		hour_passed();
	var hour_str:String;
	if current_hour < 10:
		hour_str = "0" + str(current_hour);
	else:
		hour_str = str(current_hour)
	var minute_str:String;
	
	if current_minute < 10:
		minute_str = "0" + str(current_minute);
	else:
		minute_str = str(current_minute)
		
	clock.text = hour_str + ":"+ minute_str
