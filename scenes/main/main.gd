extends Node

class_name Main;

@export var main_menu:Control;


func _ready()->void:
	Entities.main = self;


func return_to_main_menu()->void:
	get_tree().paused = false
	main_menu.show();
