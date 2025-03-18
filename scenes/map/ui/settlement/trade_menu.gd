extends Control

var player:Leader;
var settlement:Settlement;

## money trade shows separately
var money_trade:float=0;

## trade value is the change that will occur in the player's inventory
## if the trade occurs
##  positive if the resource is being bought and negative if sold
var food_trade:int=0;
var fuel_trade:int=0;

var juice_trade:int=0;
var scrap_trade:int=0;
var chips_trade:int=0;

const all_trade_resources = ["food", "fuel", "juice", "scrap", "chips"];

@export var in_trade_view:Panel;
@export var reset_btn:Button;

@export_subgroup("resource values")
@export var player_food:Label;
@export var player_fuel:Label;
@export var player_money:Label;
@export var player_juice:Label;
@export var player_scrap:Label;
@export var player_chips:Label;

@export var settlement_food:Label;
@export var settlement_fuel:Label;
@export var settlement_money:Label;
@export var settlement_juice:Label;
@export var settlement_scrap:Label;
@export var settlement_chips:Label;

@export_subgroup("trade displays")
@export var food_trade_display:HBoxContainer;
@export var fuel_trade_display:HBoxContainer;

@export var juice_trade_display:HBoxContainer;
@export var scrap_trade_display:HBoxContainer;
@export var chips_trade_display:HBoxContainer;

@export_subgroup("price labels")
@export var food_selling_price:Label;
@export var fuel_selling_price:Label;
@export var juice_selling_price:Label;
@export var scrap_selling_price:Label;
@export var chips_selling_price:Label;

@export var food_buying_price:Label;
@export var fuel_buying_price:Label;
@export var juice_buying_price:Label;
@export var scrap_buying_price:Label;
@export var chips_buying_price:Label;

## TODO: the player can buy supplies in days/hours worth of upkeep for their current party
func open()->void:
	player_money.text = "$" + str(Entities.player.inventory.money);
	settlement_money.text= "$" + str(Entities.current_settlement.inventory.money)
	player = Entities.in_map_player.leader;
	settlement = Entities.current_settlement;
	print(settlement.resource_prices)
	
	for r in all_trade_resources:
		self[r + "_trade"] = 0;
	update_values();
	show()

func clear_trade_overflows():
	for r in all_trade_resources:
		var traded = self[r+"_trade"];
		var min = Entities.player.inventory[r] * -1
		var max = Entities.current_settlement.inventory[r];
		if traded < min:
			self[r+"_trade"] = min
		if traded > max:
			self[r+"_trade"]= max;
		

func update_values():
	clear_trade_overflows();

	if visible:
		var x_roll = randi_range(-25, 25);
		var y_roll = randi_range(-25, 25);
		in_trade_view.position = Vector2(x_roll, y_roll)

		var tween = create_tween();
		tween.set_trans(Tween.TRANS_BOUNCE);
		tween.tween_property(in_trade_view, "position", Vector2.ZERO, .15)

	reset_btn.hide()
	for resource in all_trade_resources:
		print(settlement.resource_prices[resource])
		self[resource + "_selling_price"].text ="$" + str( settlement.resource_prices[resource]/2); 
		self[resource + "_buying_price"].text ="$" + str( settlement.resource_prices[resource]*2); 
		
		var traded = self[resource+"_trade"]
		
		var trade_display = self[resource+"_trade_display"]
		
		var player_current = Entities.player.inventory[resource];
		var settlement_current = Entities.current_settlement.inventory[resource];
		
		if traded:
			reset_btn.show();
			trade_display.show()
			self["player_" + resource].text = str(player_current) + " -> " + str(player_current + traded);
			self["settlement_" + resource].text = str(settlement_current) + " -> " + str(settlement_current - traded)
			
			var sold_label = trade_display.get_node("sold");
			var bought_label = trade_display.get_node("bought");
			if traded > 0:
				bought_label.show()
				bought_label.text = str(traded)
				sold_label.hide();
			else:
				sold_label.show()
				sold_label.text = str(abs(traded));
				bought_label.hide();
		else:
			self["player_" + resource].text = str(player_current)
			self["settlement_" + resource].text = str(settlement_current)
			trade_display.hide()
		


func reset_trade() -> void:
	for r in all_trade_resources:
		self[r + "_trade"] = 0;
	update_values()
