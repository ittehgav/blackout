extends Control

@export var main_ui:UIRoot
@export var main_menu:PanelContainer
@export var options_container:VBoxContainer

func load_files()->void:
	if options_container.get_child_count() == 1:
		for i:int in 5:
			var filename:String = "user://save_"+str(i + 1)+".json"
			var option:SaveFileDisplay = Index.save_file_display_scene.instantiate();
			option.load_save_file(filename, "load")
			option.pressed.connect(load_game.bind(filename));
			options_container.add_child(option)
		main_ui.recursive_connect_ui_feedback(options_container)
	

func load_game(path:String)->void:
	await Tweens.ui_fade_in(Entities.loading_screen).finished
	get_parent().hide();
	
	var data:Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	
	var map:WorldMap = Index.world_map_scene.instantiate();
	Entities.world_map = map;
	map.finished_generating.connect(Entities.loading_screen.fade_out, CONNECT_ONE_SHOT);
	map.load_game(data)
	
	Entities.main.add_child(map);
	get_parent().get_parent().remove_child(get_parent());
	
	


func _on_return_pressed() -> void:
	if visible:
		Tweens.ui_fade_out(self);
		Tweens.ui_fade_in(main_menu)
