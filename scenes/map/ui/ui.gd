extends Control

@export var settlement_ui:Control;
@export var clock:Label;

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
	
