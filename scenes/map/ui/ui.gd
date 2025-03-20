extends Control

@export var settlement_ui:Control;
@export var clock:Label;
@export var date:Label;

var current_view:Control = self;


func update_clock() -> void:
	var hour = Entities.world_map.current_hour;
	var minute = Entities.world_map.current_minute;
	
	var time_string ="";
	if hour < 10:
		time_string += "0" 
	time_string += str(hour);
	time_string += ":";
	if minute<10:
		time_string += "0";
	time_string += str(minute);
	clock.text = time_string
	
	var day = Entities.world_map.current_day;
	var month = Entities.world_map.current_month;
	
	var date_string = "";
	if day < 10:
		date_string += "0";
	date_string += str(day);
	date_string += "/";
	
	if month < 10:
		date_string += "0";
	date_string += str(month);
	
	date.text = date_string
