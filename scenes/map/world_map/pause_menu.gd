extends UIRoot

@export var main_panel:Panel;
@export var save_panel:PanelContainer;
@export var save_options_container:VBoxContainer;
@export var sound_settings:Control;

@export var load_panel:PanelContainer;
@export var load_options_container:VBoxContainer;


func _input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_pause"):
		## no pause stack = player in world map view:
		if not visible and not Entities.world_map.pause_stack:
			Tweens.ui_fade_in(self);
			Entities.world_map.pause_map();
		elif Entities.world_map.pause_stack and visible:
			if main_panel.visible:
				Tweens.ui_fade_out(self);
				Entities.world_map.unpause_map()
			elif save_panel.visible:
				Tweens.ui_fade_out(save_panel);
				Tweens.ui_fade_in(main_panel)
			elif load_panel.visible:
				Tweens.ui_fade_out(load_panel);
				Tweens.ui_fade_in(main_panel)


func _on_resume_pressed() -> void:
	Tweens.ui_fade_out(self)
	Entities.world_map.unpause_map()

func save_menu() -> void:
	Tweens.ui_fade_out(main_panel);
	Tweens.ui_fade_in(save_panel)
	
	while save_options_container.get_child_count() > 1:
		save_options_container.get_child(-1).free();
	
	for i:int in 5:
		var label:Label = Label.new();
		label.text = "SAVE FILE " + str(i + 1);
		save_options_container.add_child(label);
		
		var filename:String = "user://save_" + str(i + 1)+".json";
		var display:SaveFileDisplay = Index.save_file_display_scene.instantiate();
		display.game_saved.connect(refresh_save_panel)
		display.load_save_file(filename, "save");
		
		save_options_container.add_child(display);
	
	recursive_connect_ui_feedback(save_options_container)

func refresh_save_panel()->void:
	await Tweens.ui_fade_out(save_panel).finished;
	save_menu()

func load_menu() -> void:
	Tweens.ui_fade_out(main_panel);
	Tweens.ui_fade_in(load_panel);
	
	while load_options_container.get_child_count() > 1:
		load_options_container.get_child(-1).free();
	
	for i:int in 5:
		var label:Label = Label.new();
		label.text = "SAVE FILE " + str(i + 1);
		load_options_container.add_child(label);
		
		var filename:String = "user://save_"+str(i + 1)+".json";
		var display:SaveFileDisplay = Index.save_file_display_scene.instantiate();
		display.game_loaded.connect(load_game)
		display.load_save_file(filename, "load")
	
		load_options_container.add_child(display)
		
	recursive_connect_ui_feedback(load_options_container)



func return_to_main_view() -> void:
	Tweens.ui_fade_out(save_panel);
	Tweens.ui_fade_out(load_panel);
	Tweens.ui_fade_in(main_panel)

func load_game(data:Dictionary)->void:
	await Tweens.ui_fade_in(Entities.loading_screen).finished

	Entities.world_map.free();
	
	var new_map:WorldMap = Index.world_map_scene.instantiate();
	Entities.world_map = new_map;
	new_map.finished_generating.connect(Entities.loading_screen.fade_out, CONNECT_ONE_SHOT);
	new_map.load_game(data);
	
	Entities.main.add_child(new_map);
	Entities.main.move_child(new_map, 0)


func _on_return_confirm_pressed() -> void:
	Entities.main.return_to_main_menu();



func _on_return_cancel_pressed() -> void:
	Tweens.ui_fade_out($main_menu_confirmation);
	Tweens.ui_fade_in($main_panel);


func _on_main_menu_pressed() -> void:
	Tweens.ui_fade_out($main_panel);
	Tweens.ui_fade_in($main_menu_confirmation);


func _on_sound_settings_pressed() -> void:
	sound_settings.show_settings($main_panel)
