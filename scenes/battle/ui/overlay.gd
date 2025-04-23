extends Control

@export var in_fight_player:InFightPlayer;
@export var post_fight:Control;
@export var tide_bar:TextureProgressBar;
@export var pause_menu:Control;




func _input(e:InputEvent)->void:
	if e.is_action_pressed("ui_pause") and Entities.arena.battle_ongoing:
		if not get_tree().paused:
			pause_menu.start()
		else:
			pause_menu.resume()
