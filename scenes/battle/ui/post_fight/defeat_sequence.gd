extends Control

@export var morale_icon:MoraleIcon;

@export var defeat_view:PanelContainer;
@export var game_over_view:PanelContainer

func start_sequence()->void:
	show()
	var player:Player = Entities.player;
	player.morale -= 1 + player.morale/5;
	if player.morale < 0:
		Tweens.ui_fade_in(game_over_view)
		
	else:
		Tweens.ui_fade_in(defeat_view)
		morale_icon.animated_update();


func _on_return_to_main_menu_pressed() -> void:
	State.set_scenario(State.Scenario.main)
