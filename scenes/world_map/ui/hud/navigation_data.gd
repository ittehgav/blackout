extends PanelContainer

## TODO unexport this when entities are declared before loading htis scene
@export var sfx:SfxPlayer
@export var player_party:PlayerParty

@export var title_label:Label;
@export var location_sprite:TextureRect;

## also the name of the current settlement when not hovering anything
@export var distance_label:Label;
@export var travel_time_label:Label;

@export var travel_cost_display:HBoxContainer;
@export var food_cost_label:Label;
@export var fuel_cost_label:Label;

func _ready()->void:
	display_current_settlement()
	
func display_current_settlement(target:Settlement = Entities.player_party.current_settlement)->void:
	if not player_party.current_settlement:
		return
	travel_cost_display.hide()
	travel_time_label.text = "";
	
	title_label.text = "Current Location"
	distance_label.text = target.name;
	location_sprite.texture = target.get_node("sprite").texture;



func display_travel_data(target:Settlement)->void:
	if target == player_party.current_settlement:
		return;
	travel_cost_display.show()
	
	title_label.text = target.name;
	var cell_distance:int = Entities.road.get_settlement_distance(player_party.current_settlement, target);
	var km_distance:int = Index.cell_to_km * cell_distance;
	
	distance_label.text = str(km_distance) + " km"
	var travel_hours:int;
	var travel_minutes:float = (km_distance/player_party.navigation_speed) * 60
	
	while travel_minutes > 60:
		travel_hours += 1;
		travel_minutes -= 60;
	
	var travel_time_string:String;
	if travel_hours:
		var hours_string:String
		if travel_hours < 10:
			hours_string = "0" + str(travel_hours);
		else:
			hours_string = str(travel_hours)
			
		var minutes_string:String
		if travel_minutes < 10:
			minutes_string = "0" + str(travel_minutes);
		else:
			minutes_string = str(travel_minutes)
		travel_time_string = hours_string + ":" + minutes_string;
	else:
		travel_time_string = "00:" + str(travel_minutes)
	travel_time_label.text = travel_time_string
	
	
	var costs:Dictionary = Entities.player.travel_upkeep_cost();
	var upkeep_hits:int = (travel_hours + travel_minutes/60) * 2
	food_cost_label.text = str(costs.food * upkeep_hits);
	fuel_cost_label.text = str(costs.fuel * upkeep_hits);
		


func _on_player_upkeep_food_shortage() -> void:
	sfx.play_sound_by_key("food_shortage")


func _on_player_upkeep_fuel_shortage() -> void:
	sfx.play_sound_by_key("fuel_shortage")


func _on_player_upkeep_paid_fully() -> void:
	sfx.play_sound_by_key("upkeep_paid")
