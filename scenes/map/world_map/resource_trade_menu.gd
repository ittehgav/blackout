extends Control

var player:Leader;
var settlement:Settlement;

## trade value is the change that will occur in the player's inventory
## if the trade occurs
## ie positive if the resource is being bought and negative if sold
var money_trade:float=0;
var food_trade:int=0;
var fuel_trade:int=0;

var juice_trade:int=0;
var scrap_trade:int=0;
var chips_trade:int=0;

@export var player_trade_card:Panel;
@export var settlement_trade_card:Panel;

@export var confirm_btn:Button;

func open()->void:
	player = Entities.in_map_player.leader;
	settlement = Entities.current_settlement;
	
	player_trade_card.holder = player;
	settlement_trade_card.holder = settlement;
	
	refresh_values();
	show()


func refresh_values()->void:
	set_money_trade();
	set_confirm_availability();
	player_trade_card.update_values()
	settlement_trade_card.update_values();
	
func set_confirm_availability()->void:
	confirm_btn.disabled =\
	player.inventory.money < money_trade * -1 or \
	settlement.inventory.money < money_trade


		
func set_money_trade()->void:
	var sell_values:Dictionary = Entities.current_settlement.get_resource_values("sell");
	var buy_values:Dictionary = Entities.current_settlement.get_resource_values("buy")

	money_trade = 0;
	
	if food_trade < 0:
		money_trade += sell_values["food"] * abs(food_trade)
	else:
		money_trade -= buy_values["food"] * food_trade
		
	if fuel_trade < 0:
		money_trade += sell_values["fuel"] * abs(fuel_trade)
	else:
		money_trade -= buy_values["fuel"] * fuel_trade
		
	if juice_trade < 0:
		money_trade += sell_values["juice"] * abs(juice_trade)
	else:
		money_trade -= buy_values["juice"] * juice_trade
		
	if scrap_trade < 0:
		money_trade += sell_values["scrap"] * abs(scrap_trade)
	else:
		money_trade -= buy_values["scrap"] * scrap_trade
		
	if chips_trade < 0:
		money_trade += sell_values["chips"] * abs(chips_trade)
	else:
		money_trade -= buy_values["chips"] * chips_trade
	

func get_resource_values(trader)->Dictionary:
	if trader is Player:
		return Entities.current_settlement.get_resource_values("buy");
	else:
		return Entities.current_settlement.get_resource_values("sell")


func confirm_trade() -> void:
	player.inventory.food += food_trade;
	food_trade = 0
	player.inventory.money += money_trade;
	money_trade = 0
	player.inventory.fuel += fuel_trade;
	fuel_trade = 0


	player.inventory.juice += juice_trade;
	juice_trade = 0
	player.inventory.scrap += scrap_trade;
	scrap_trade = 0
	player.inventory.chips += chips_trade;
	chips_trade = 0
	refresh_values()
	Entities.player.resources_changed.emit()

func _on_settlement_ui_settlement_entered() -> void:
	money_trade=0;
	food_trade=0;
	fuel_trade=0;

	juice_trade=0;
	scrap_trade=0;
	chips_trade=0;
