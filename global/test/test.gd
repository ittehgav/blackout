extends Node

var test_start_time:float;

func start_time_track()->void:
	print("start time track \n")
	test_start_time = Time.get_unix_time_from_system();

func time_elapsed(to_print:String)->void:
	print(Time.get_unix_time_from_system() - test_start_time, " ", to_print)
