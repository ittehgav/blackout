extends UIRoot



@export var load_menu:Control;
@export var main_view:Control;

@export var load_btn:Button;

@export var new_game_overlay:Control;

@export var full_screen_hint_arrow:TextureRect

func _ready()->void:
	super()
	var no_save_files:bool=true;
	for i:int in 5:
		if FileAccess.file_exists("user://save_"+str(i + 1)+".json"):
			no_save_files=false;
			break;
	
	if no_save_files:
		load_btn.disabled = true;
	full_screen_hint_loop();
	
@onready var arrow_origin:float = full_screen_hint_arrow.position.x;
func full_screen_hint_loop()->void:
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC)
	full_screen_hint_arrow.position.x = arrow_origin;
	tween.tween_property(full_screen_hint_arrow, "position:x", arrow_origin + 50, .75);
	tween.tween_callback(full_screen_hint_loop)


	



func _on_load_pressed() -> void:
	await Tweens.ui_fade_out(main_view).finished
	Tweens.ui_fade_in(load_menu);
	load_menu.load_files();
	


func _on_new_game_pressed() -> void:
	Tweens.ui_fade_out(main_view)
	Tweens.ui_fade_in(new_game_overlay);



func _on_full_scree_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);


func _on_button_pressed() -> void:
	
	
	
	## all states besides world map do the state machine call on their _ready functions,
	## world map's call happens after world_map is back into the tree 
	## from the call that brought it back
	Entities.main.set_scenario("world_map")
	await Entities.main.scenario_changed
	get_parent().queue_free();


func _on_button_2_pressed() -> void:
	Entities.main.set_scenario("test_arena")
	get_parent().queue_free()
