extends Control

@export var main_ui:UIRoot
@export var main_menu:Control
@export var options_container:VBoxContainer

func load_files()->void:
	if options_container.get_child_count() == 1:
		for i:int in 5:
			var filename:String = "user://save_"+str(i + 1)+".json"
			var option:SaveFileDisplay = Index.scenes.ui.save_file_display.instantiate();
			option.load_save_file(filename, "load")
			option.pressed.connect(load_game.bind(filename));
			options_container.add_child(option)
		main_ui.recursive_connect_ui_feedback(options_container)
	

func load_game(path:String)->void:
	await Tweens.ui_fade_in(Entities.loading_screen).finished
	get_parent().hide();
	
	var data:Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var map:WorldMap = Index.scenes.world_map.instantiate();
	Entities.world_map = map;
	map.finished_generating.connect(Entities.loading_screen.fade_out, CONNECT_ONE_SHOT);
	map.load_game(data)
	
	Entities.main.add_child(map);
	Entities.main.move_child(map, 0)
	get_parent().get_parent().queue_free()


	
	


func _on_return_pressed() -> void:
	if modulate.a == 1:
		Tweens.ui_fade_out(self);
		Tweens.ui_fade_in(main_menu)
