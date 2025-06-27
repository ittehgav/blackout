extends Control

@export var exp_gains:Panel;
@export var loot_gains:PanelContainer;

func victory_animation()->void:
	show()
	loot_gains.setup();
	exp_gains.distribute_exp();

func show_loot()->void:
	await Tweens.ui_fade_out(exp_gains).finished;
	Tweens.ui_fade_in(loot_gains)
	loot_gains.animate_money_gain()
