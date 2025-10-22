extends Control

@export var post_battle:Control;

@export var exp_panel:Panel;
@export var level_up_panel:Panel;
@export var loot_panel:Panel

func play_animation()->void:
	show();
	exp_panel.show()
	exp_panel.distribute_exp();
	

func _on_exp_gains_continue_pressed() -> void:
	Tweens.ui_fade_out(exp_panel);
	if level_up_panel.queue:
		level_up_panel.display_perks();
	else:
		Tweens.ui_fade_in(loot_panel)




func _on_level_up_rewards_leveling_finished() -> void:
	Tweens.ui_fade_out(level_up_panel);
	Tweens.ui_fade_in(loot_panel);
