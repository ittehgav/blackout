extends Control

@export var post_battle:Control;

@export var exp_panel:Panel;
@export var loot_panel:Panel

func play_animation()->void:
	show();
	exp_panel.show()
	exp_panel.distribute_exp();
	
	


func _on_continue_to_loot_pressed() -> void:
	Tweens.ui_fade_out(exp_panel);
	Tweens.ui_fade_in(loot_panel)
