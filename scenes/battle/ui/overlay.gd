extends Control

@export var player_fighter:InFightPlayer;
@export var post_fight:Control;
@export var tide_bar:TextureProgressBar;
@export var pause_menu:Control;


func _input(e:InputEvent)->void:
	if e.is_action_pressed("ui_pause") and not post_fight.visible:
		if not get_tree().paused:
			pause_menu.start();
		else:
			pause_menu.resume();
