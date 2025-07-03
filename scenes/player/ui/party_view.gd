extends Control

@export var food_cost:Label;
@export var fuel_cost:Label;

@export var ui_sfx:AudioStreamPlayer;

@export var recruit_full_view:Panel;

@export var recruits_grid:GridContainer;

@export var upgrade_hint:TextureRect

func refresh_data()->void:
	for c in recruits_grid.get_children():
		c.queue_free()
	
	for unit:FighterUnit in Entities.player.roster.units:
		var sample:SpriteSample = Index.sprite_sample_scene.instantiate();
		sample.get_node("additional_data").text = "Lv. " + str(unit.level);
		sample.set_sample(unit.base.duplicate());
		recruits_grid.add_child(sample)
		sample.pressed.connect(show_more.bind(unit))
		
		if unit.upgrade_available():
			var hint:TextureRect = upgrade_hint.duplicate();
			hint.show()
			sample.add_child(hint)
			if not unit.upgrade_affordable():
				hint.modulate.v = 0;
				hint.modulate.a = .5;
		
	
	var travel_expenses:Dictionary = Entities.player.travel_upkeep_cost();
	food_cost.text = str(travel_expenses.food) + "/hour"
	fuel_cost.text = str(travel_expenses.fuel) + "/hour"
		
		
func show_more(unit:FighterUnit)->void:
	ui_sfx.play_stream("button_click")
	recruit_full_view.display_recruit(unit)
