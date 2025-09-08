extends Node

@export_enum("main", "world_map", "location", "battle") var state:String;

@export var main_menu_ui_scene:PackedScene;
signal state_changed(new_state:String);


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


func _on_state_changed(new_state: String) -> void:
	state = new_state;
