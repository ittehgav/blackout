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


	



func _on_load_pressed() -> void:
	await Tweens.ui_fade_out(main_view).finished
	Tweens.ui_fade_in(load_menu);
	load_menu.load_files();
	


func _on_new_game_pressed() -> void:
	Tweens.ui_fade_out(main_view)
	Tweens.ui_fade_in(new_game_overlay);


func _on_button_pressed() -> void:
	## all states besides world map do the state machine call on their _ready functions,
	## world map's call happens after world_map is back into the tree 
	## from the call that brou ght it back
	hide()
	State.set_scenario(State.Scenario.world_map)
	


func _on_button_2_pressed() -> void:
	get_parent().hide()
	State.set_scenario(State.Scenario.tutorial)
