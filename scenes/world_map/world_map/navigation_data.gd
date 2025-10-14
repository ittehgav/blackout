extends PanelContainer

var current_target:Settlement

@warning_ignore("shadowed_global_identifier")
@export var sign:SettlementSign

@export var name_label:Label;
@export var eta_label:Label;

@export var food_cost_label:Label;
@export var fuel_cost_label:Label;

@export var arrow:Sprite2D;



func show_settlement(target:Settlement)->void:
	name_label.text = target.unique_name
	set_travel_data(target);
	Tweens.ui_fade_in(self);

func set_travel_data(target:Settlement)->void:
	current_target = target
	sign.load_settlement(target)
	var player_party:PlayerParty = Entities.player_party;

	var travel_minutes:int = Entities.player_party.get_travel_minutes(target);
	var travel_hours:int=0;
	
	while travel_minutes > 60:
		travel_hours += 1;
		travel_minutes -= 60;
	
	var days_passed:int = 0;
	var arrival_hour:int = Entities.world_map.current_hour + travel_hours;
	var arrival_minute:int = Entities.world_map.current_minute + travel_minutes;

	while arrival_minute > 60:
		arrival_minute -= 60;
		arrival_hour += 1;

	while arrival_hour >= 24:
		days_passed += 1;
		arrival_hour -= 24
		
	var hour_string:String = str(arrival_hour)+":";
	var minute_string:String = str(arrival_minute);
	
	if arrival_hour < 10:
		hour_string = "0"+hour_string
	if arrival_minute < 10:
		minute_string = "0"+minute_string
	
	var days_string:String = "";
	if days_passed:
		days_string = " ("+str(days_passed)+")"

	eta_label.text = "Arrival By "+hour_string + minute_string + days_string;
	
	var costs:Dictionary[String, int] = Entities.player_party.get_travel_cost(target)

	if costs.food > Entities.player.inventory.food or\
		costs.fuel > Entities.player.inventory.fuel:
			modulate = Color.DARK_RED
			arrow.hide();
	else:
		modulate = Color.WHITE;
		arrow.show();
	
	food_cost_label.text = str(costs.food);
	fuel_cost_label.text = str(costs.fuel)


func _on_button_pressed() -> void:
	clear();
	Entities.player_party.move_to_settlement(current_target)
func _on_player_party_started_moving() -> void:
	clear();
func _on_world_map_camera_started_panning() -> void:
	clear();

func clear()->void:
	Tweens.ui_fade_out(self)
	Entities.road.clear_path_highlight()
