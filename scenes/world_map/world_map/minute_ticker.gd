extends Timer

@export var world_map:WorldMap;

const minutes_per_tick = 1
func _ready()->void:
	wait_time = 60/Index.irl_time_scale * minutes_per_tick


func _on_timeout() -> void:
	world_map.current_minute += minutes_per_tick
	if world_map.current_minute >= 60:
		world_map.current_minute = 0;
		advance_hour();

func advance_hour()->void:
	world_map.current_hour += 1;
	if world_map.current_hour == 24:
		world_map.current_hour = 0;
		world_map.advance_day()
	world_map.hour_passed.emit();



func advance_month()->void:
	world_map.current_month += 1;
	if world_map.current_month == 13:
		advance_year();

func advance_year()->void:
	world_map.current_year += 1;
