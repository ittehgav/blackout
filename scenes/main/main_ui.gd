extends UIRoot

@export var load_menu:Control;
@export var main_options_container:Container;

@export var load_btn:Button;

@export var new_game_overlay:Control;

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
	await Tweens.ui_fade_out(main_options_container)
	Tweens.ui_fade_in(load_menu);
	load_menu.load_files();
	


func _on_new_game_pressed() -> void:
	Tweens.ui_fade_out(main_options_container)
	Tweens.ui_fade_in(new_game_overlay);
