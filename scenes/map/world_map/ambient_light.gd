extends CanvasModulate

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


func update_lighting()->void:
	var index:int = Entities.world_map.current_hour;
	if index >= 11:
		index -= 11
	var tween:Tween = create_tween();
	tween.tween_property(self, "color", cycle_colors[index], 1);

func _input(e:InputEvent)->void:
	if e.is_action_pressed("move_right"):
		get_tree().paused = false;
