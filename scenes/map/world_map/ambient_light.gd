extends CanvasModulate

var current_hour:int=0;
var current_minute:int=0;

@export var clock:Label;

@export var cycle_colors:Array[Color] = [
	Color.MIDNIGHT_BLUE + Color(-.2, -.2, -.2, -.2), ## 00:00
	Color.MIDNIGHT_BLUE + Color(-.2, -.2, -.2, -.2), ## 01:00 / 23:00
	Color.MIDNIGHT_BLUE + Color(-.2, -.2, -.2, -.2), ## 02:00 / 22:00
	Color.MIDNIGHT_BLUE * 1.2 + Color(-.1, -.1, -.1, -.5), ## 03:00 / 21:00
	Color.MIDNIGHT_BLUE * 1.5 + Color(0, 0, 0, -.6), ## 04:00 / 20:00
	Color.SKY_BLUE * .75 + Color(0, 0, 0, 1), ## 05:00 / 19:00
	Color.SKY_BLUE * Color.SANDY_BROWN + Color(0, 0, 0, 1), ## 6:00 / 18:00
	Color.SANDY_BROWN + Color(0, 0, 0, 1), ## 07:00 / 17:00
	Color.SANDY_BROWN * 1.2 + Color(0, 0, 0, 1), ##08:00 / 16:00
	Color.SANDY_BROWN * 1.4 + Color(0, 0, 0, 1), ##09:00 / 15:00
	Color.SANDY_BROWN * 1.5 + Color(0, 0, 0, 1), ##10:00 / 14:00 
	Color.SANDY_BROWN * 1.5 + Color(0, 0, 0, 1), ##11:00 / 13:00
	Color.SANDY_BROWN * 1.5 + Color(0, 0, 0, 1), ##12:00
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
	var index = current_hour;
	if index > 11:
		index = 12 - (index - 11)
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
	#var minute_str:String;
	#
	#if current_minute < 10:
		#minute_str = "0" + str(current_minute);
	#else:
		#minute_str = str(current_minute)
		
	#clock.text = hour_str + ":"+ minute_str


func _input(e:InputEvent):
	if e.is_action_pressed("move_right"):
		get_tree().paused = false;
