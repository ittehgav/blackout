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



@export var confirm_btn:Button;

func open()->void:
	player = Entities.in_map_player.leader;
	settlement = Entities.current_settlement;
	
	show()
