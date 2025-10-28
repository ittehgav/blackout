extends UIRoot

@export var victory_view:Control;
@export var defeat_view:Control;

func _ready()->void:
	hide()
	## to make testing simpler
	victory_view.hide();
	victory_view.exp_panel.hide();
	victory_view.loot_panel.hide()
	defeat_view.hide()


func show_post_fight()->void:
	show();
	victory_view.hide();
	defeat_view.hide()
	if Entities.arena.won_battle:
		Entities.player.battle_won()
		victory_view.play_animation();
	else:
		## battle lost call in the defeat view so it's easier to get the losses
		Entities.player.battle_lost();
		defeat_view.play_animation()


func _on_finish_arena_pressed() -> void:
	Entities.player.inventory.changed.emit()
	await Entities.loading_screen.show_splash().finished;
	Entities.main.set_scenario("world_map")
	
