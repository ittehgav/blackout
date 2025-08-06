extends Timer

@export var world_map:WorldMap;

func _ready()->void:
	wait_time = 60/Index.irl_time_scale

func _on_timeout() -> void:
	world_map.current_minute += 1;
	if world_map.current_minute == 60:
		world_map.current_minute = 0;
		advance_hour();

func advance_hour()->void:
	world_map.hour_passed.emit();
	world_map.current_hour += 1;
	if world_map.current_hour == 24:
		world_map.current_hour = 0;
		advance_day()

func advance_day()->void:
	world_map.day_passed.emit()
	world_map.current_day += 1;
	if world_map.current_day == 32:
		advance_month();
		world_map.current_day = 0;

func advance_month()->void:
	world_map.current_month += 1;
	if world_map.current_month == 13:
		advance_year();

func advance_year()->void:
	world_map.current_year += 1;
