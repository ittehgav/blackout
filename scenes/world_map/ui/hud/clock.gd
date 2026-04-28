extends PanelContainer

@export var date_label:Label;
@export var hour_label:Label;

@onready var world_map:WorldMap = get_tree().get_first_node_in_group("world_map")

func refresh_date()->void:
	var day:int = world_map.current_day;
	var month:int = world_map.current_month;
	var day_string:String;
	var month_string:String;
	if day < 10:
		day_string = "0" + str(day)
	else:
		day_string = str(day);
	if month < 10:
		month_string = "0" + str(month);
	else:
		month_string = str(month);
	date_label.text = day_string + "/" + month_string + "/" + str(world_map.current_month);


func refresh_clock()->void:
	var hour:int = world_map.current_hour;
	var minute:int = world_map.current_minute;
	
	var hour_string:String;
	var minute_string:String;
	if hour < 10:
		hour_string = "0" + str(hour);
	else:
		hour_string = str(hour);
	if minute < 10:
		minute_string = "0" + str(minute);
	else:
		minute_string = str(minute);
	hour_label.text = hour_string + ":" + minute_string;
	


func _on_minute_ticker_timeout() -> void:
	refresh_clock();


func _on_world_map_ready() -> void:
	refresh_clock();
	refresh_date()
