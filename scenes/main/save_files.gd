extends PanelContainer

@export var save_file_button:Button;
@export var options_container:VBoxContainer

func load_files()->void:
	var option:Button = save_file_button.duplicate();
	option.load_save_file("user://savegame.json")
	option.pressed.connect(load_game.bind("user://savegame.json"));
	options_container.add_child(option)
	

func load_game(file:String)->void:
	await Tweens.ui_fade_in(Entities.loading_screen).finished
	get_parent().hide();
	var data:Dictionary = JSON.parse_string(FileAccess.get_file_as_string(file));
	
	var map:WorldMap = Index.world_map_scene.instantiate();
	Entities.world_map = map;
	map.finished_generating.connect(Entities.loading_screen.fade_out, CONNECT_ONE_SHOT);
	map.load_game(data)
	map.player_party.setup()
	
	Entities.main.add_child(map);
	get_parent().get_parent().remove_child(get_parent());
	
	
