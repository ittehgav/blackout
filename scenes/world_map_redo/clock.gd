extends PanelContainer

@export var date_label:Label;
@export var hour_label:Label;

func refresh_date()->void:
	var day:int = Entities.world_map.current_day;
	var month:int = Entities.world_map.current_month;
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
	date_label.text = day_string + "/" + month_string + "/" + str(Entities.world_map.current_month);


func refresh_clock()->void:
	var hour:int = Entities.world_map.current_hour;
	var minute:int = Entities.world_map.current_minute;
	
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
	if not Entities.world_map.current_minute % 5:
		refresh_clock();
