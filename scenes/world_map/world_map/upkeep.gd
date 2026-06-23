extends Node

signal paid_fully
signal food_shortage
signal fuel_shortage

signal game_over

@export var player_party:PlayerParty;

@onready var player:Player = get_tree().get_first_node_in_group("player");



func travel_upkeep()->void:
	## EVERY 30 IGT MINUTES
	var cost:Dictionary = player.travel_upkeep_cost();
	var missing_food:int = 0;
	var missing_fuel:int = 0;
	
	if player.inventory.food >= cost.food:
		player.inventory.change_resource("food", cost.food * -1);
	else:
		missing_food = cost.food - player.inventory.food;
		player.inventory.change_resource("food", player.inventory.food * -1)
		
	if player.inventory.fuel >= cost.fuel:
		player.inventory.change_resource("fuel", cost.fuel * -1)
	else:
		missing_fuel = cost.fuel - player.inventory.fuel;
		player.inventory.change_resource("fuel", player.inventory.fuel * -1);
	
	
	if not missing_food and not missing_fuel:
		paid_fully.emit();
		
	
	if missing_food:
		food_shortage.emit()
		var morale_loss:float = -1 - player.morale/5;
		player.change_morale(morale_loss);
		if player.morale < 0:
			get_tree().paused = true;
			game_over.emit()
			## likely will eventually have more conditions other than the car being moving
			return

	if missing_fuel:
		fuel_shortage.emit()
		## speed will halve every hour down to a bottom cap
		player_party.navigation_speed /= 2;
		if player_party.navigation_speed < 5:
			player_party.navigation_speed = 5
		## need to manually slow down current tween 
		## bc it's easier than recalculating everything?

	
	player.inventory.refresh_resource_counts()


func _on_return_to_main_menu_pressed() -> void:
	State.set_scenario(State.Scenario.main);
