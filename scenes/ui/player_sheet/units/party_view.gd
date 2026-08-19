extends Control

class_name PartyView;

signal unit_accessories_changed

@export var party_power_icon:PartyPowerIcon

@export var food_cost:Label;
@export var fuel_cost:Label;

@export var ui_sfx:AudioStreamPlayer;

@export var unit_sheet_scene:PackedScene;

@export var units_grid:GridContainer;



@onready var player:Player = Entities.player

@export var party_cap_label:Label;

func _ready()->void:
	Entities.player.inventory.changed.connect(refresh_data)

func refresh_data()->void:
	for c in units_grid.get_children():
		c.queue_free()
	party_power_icon.refresh()
	
	for unit:FighterUnit in player.roster.units:
		var sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
		sample.load_unit(unit, show_more.bind(unit))
		units_grid.add_child(sample)
	
	var travel_expenses:Dictionary = player.travel_upkeep_cost();
	food_cost.text = str(travel_expenses.food) + "/hour"
	fuel_cost.text = str(travel_expenses.fuel) + "/hour"
		
	var current_count:String = str(len(Entities.player.roster.units));
	var cap:String = str(Entities.player.party_cap);
	party_cap_label.text = current_count+"/"+cap
var current_unit_sheet:UnitSheet;
func show_more(unit:FighterUnit)->void:
	ui_sfx.play_stream("button_click")
	current_unit_sheet = unit_sheet_scene.instantiate();
	Entities.player_sheet.add_child(current_unit_sheet)
	current_unit_sheet.display_unit(unit)
	current_unit_sheet.set_anchors_preset(PRESET_CENTER)
