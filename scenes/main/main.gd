extends Node

class_name Main;

@export var main_menu_ui_scene:PackedScene;

@export var main_bgm:AudioStreamPlayer

func _ready()->void:
	Entities.main = self;

#func return_to_main_menu()->void:
#
	#Entities.world_map.free();
	#get_tree().paused = false
	#
	#var main_menu_ui:CanvasLayer = main_menu_ui_scene.instantiate();
#
	#add_child(main_menu_ui)
	#move_child(main_menu_ui, 1)
