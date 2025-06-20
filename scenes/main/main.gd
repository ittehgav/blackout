extends Node

@export var main_menu_ui_scene:PackedScene;
var current_state:String = "main"

func _ready()->void:
	Entities.main = self;
	
func return_to_main_menu()->void:
	await Tweens.ui_fade_in(Entities.loading_screen).finished;
	Entities.world_map.free();
	get_tree().paused = false
	
	var main_menu_ui:CanvasLayer = main_menu_ui_scene.instantiate();
	main_menu_ui.tree_entered.connect(Entities.loading_screen.fade_out)
	add_child(main_menu_ui)
	move_child(main_menu_ui, 1)
