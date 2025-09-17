extends Control

class_name PartyView;

signal unit_accessories_changed

@export var food_cost:Label;
@export var fuel_cost:Label;

@export var ui_sfx:AudioStreamPlayer;

@export var unit_sheet_scene:PackedScene;

@export var units_grid:GridContainer;

@export var upgrade_hint:TextureRect

func refresh_data()->void:
	for c in units_grid.get_children():
		c.queue_free()
	
	for unit:FighterUnit in Entities.player.roster.units:
		var sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
		sample.load_unit(unit, show_more.bind(unit))
		units_grid.add_child(sample)
		
		if unit.upgrade_available():
			var hint:TextureRect = upgrade_hint.duplicate();
			hint.show()
			sample.add_child(hint)

		
	
	var travel_expenses:Dictionary = Entities.player.travel_upkeep_cost();
	food_cost.text = str(travel_expenses.food) + "/hour"
	fuel_cost.text = str(travel_expenses.fuel) + "/hour"
		
var current_unit_sheet:UnitSheet;
func show_more(unit:FighterUnit)->void:
	ui_sfx.play_stream("button_click")
	current_unit_sheet = unit_sheet_scene.instantiate();
	Entities.player_sheet.add_child(current_unit_sheet)
	current_unit_sheet.display_unit(unit)
	current_unit_sheet.set_anchors_preset(PRESET_CENTER)
