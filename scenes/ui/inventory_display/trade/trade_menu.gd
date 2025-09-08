extends UIRoot
class_name TradeMenu;

signal trade_started;
signal trade_finished;


@export var player_inventory_display:InventoryDisplay;
@export var trader_inventory_display:InventoryDisplay;

@export var confirm_btn:Button;
@export var reset_btn:Button;

@export var player_name_label:Label;
@export var trader_name_label:Label;

var trade_volume:int = 0;

var non_resource_money_trade:int = 0;
var money_trade:int=0;
## the player can never buy and sell the same resource in the same transaction
var food_trade:int = 0;
var fuel_trade:int = 0;
var juice_trade:int = 0;
var scrap_trade:int = 0;
var chips_trade:int = 0;


@export_group("trade labels")
@export var money_trade_label:Label;

@export var food_trade_label:Label;
@export var fuel_trade_label:Label;
@export var juice_trade_label:Label;
@export var scrap_trade_label:Label;
@export var chips_trade_label:Label;

@export_group("Quick-Buy")
var food_hourly_cost:int;
var fuel_hourly_cost:int;

@export var food_hourly_cost_label:Label;
@export var food_daily_cost_label:Label;

@export var fuel_hourly_cost_label:Label;
@export var fuel_daily_cost_label:Label;

func start_trade(target:Inventory, target_name:String)->void:
	## initiation routines require both inventories to be assigned
	player_name_label.text = Entities.player.name;
	trader_name_label.text = target_name
	
	## needs to load trader first because buying/selling prices are defined by the NPC
	trader_inventory_display.set_grid();
	trader_inventory_display.load_inventory(target);
	trader_inventory_display.set_reset_state()
	
	player_inventory_display.set_grid()
	player_inventory_display.load_inventory(Entities.player.inventory)
	player_inventory_display.set_reset_state()
	
	## re-refreshing to make them account for eachother 
	## when setting up th resource dropdowns
	player_inventory_display.refresh_data()
	trader_inventory_display.refresh_data()

	
	reset_trade_balance()
	player_inventory_display.warnings_popup.hide();
	
	trade_started.emit();

	var upkeep_cost:Dictionary = Entities.player.travel_upkeep_cost();
	food_hourly_cost = upkeep_cost.food * 3;
	fuel_hourly_cost = upkeep_cost.fuel * 3;
	
	food_hourly_cost_label.text = str(food_hourly_cost)
	food_daily_cost_label.text = str(food_hourly_cost * 24)
	
	fuel_hourly_cost_label.text = str(fuel_hourly_cost)
	fuel_daily_cost_label.text = str(fuel_hourly_cost * 24)
	

func refresh_trade_balance()->void:
	confirm_btn.disabled = false;
	money_trade = non_resource_money_trade;
	trade_volume = money_trade;


	reset_btn.disabled = true;

	for r:String in Index.all_resources.filter(func(r:String)->bool:return r != "money"):
		var trade:int = self[r+"_trade"]
		if trade < 0:
			## TRADE < 0 = PLAYER SELLING
			## trade is negative here so money_trade gets subtracted and volume added
			reset_btn.disabled = false
			var value:int = trader_inventory_display.inventory.resource_selling_prices[r] * trade
			## value is subtracted because it's negative
			money_trade -= value;
			trade_volume += value;
		elif trade > 0:
			## TRADE > 0 = PLAYER BUYING
			reset_btn.disabled = false;
			var value:int = trader_inventory_display.inventory.resource_buying_prices[r] * trade
			money_trade -= value;
			trade_volume += value 

	for r:String in Index.all_resources:
		var label:Label = self[r+"_trade_label"];
		label.text = "";
		
		var trade:int;
		if r != "money":
			trade = self[r + "_trade"]
		else:
			trade = money_trade;


		if trade:
			reset_btn.disabled = false;
			if trade > 0:
				## TRADE > 0 = PLAYER BUYING
				label.text = str(trade);
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT;
				label.add_theme_color_override("font_color", Color.GREEN);
			else:
				## TRADE < 0 = PLAYER SELLING	
				label.text = str(-trade);
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT;
				label.add_theme_color_override("font_color", Color.YELLOW);
				
	if trader_inventory_display.inventory.money < money_trade or\
	player_inventory_display.inventory.money < -money_trade:
		confirm_btn.disabled = true;
		money_trade_label.add_theme_color_override("font_color", Color.GRAY.darkened(.5));
	else:
		money_trade_label.add_theme_color_override("font_color", Index.resource_colors["money"]);
	


func _on_player_inventory_display_resources_changed(resource: String, amount: int) -> void:
	## positive change on player's inventory = balance UP
	## negative change on player's inventory = balance DOWN
	self[resource+"_trade"] += amount;
	refresh_trade_balance();

func _on_trader_inventory_display_item_received(mirror:ItemMirror, from:String="move") -> void:
	## ITEM DROPPED IN TRADER INVENTORY = SOLD
	if from == "trade" and (not mirror.item is ResourceContainer or \
	(not mirror.item.raw_stack and mirror.stack_size == 0)):
		non_resource_money_trade += mirror.price;
		refresh_trade_balance()


func _on_player_inventory_display_item_received(mirror:ItemMirror, from:String="move") -> void:
	## ITEM DROPPED IN PLAYER INVENTORY = BOUGHT
	if from == "trade" and (not mirror.item is ResourceContainer or \
	(not mirror.item.raw_stack and mirror.stack_size == 0)):
		non_resource_money_trade -= mirror.price;
		refresh_trade_balance()


func _on_confirm_pressed() -> void:
	if player_inventory_display.pending_warnings():
		player_inventory_display.warn_player();
		var clear:bool = await player_inventory_display.warnings_attended;
		if clear:
			finish_trade();
	else:
		finish_trade();


func _on_reset_pressed() -> void:
	player_inventory_display.reset_inventory();
	trader_inventory_display.reset_inventory();
	reset_trade_balance()
	
	player_inventory_display.sfx.play_sound_by_key("reset");

func reset_trade_balance()->void:
	for r:String in Index.all_resources:
		if r != "money":
			self[r+"_trade"] = 0;
			## money trade is more dynamic than other resources

	non_resource_money_trade = 0;
	trade_volume = 0;

	refresh_trade_balance()


func finish_trade()->void:
	const tween_duration = 1.25
	

	for r:String in Index.all_resources:
		var trade:int = self[r+"_trade"];
		if trade:
			var tween:Tween = create_tween();

			
			tween.set_ease(Tween.EASE_OUT);
			tween.set_trans(Tween.TRANS_QUINT)

			var trade_label:Label = self[r+"_trade_label"];

			tween.tween_property(trade_label, "text", str(0), tween_duration)
			tween.tween_callback(trade_label.set_text.bind(""))

	
	player_inventory_display.inventory.money += money_trade
	if money_trade:
		Entities.player.resource_changed.emit.call_deferred("money", money_trade)
	
	trader_inventory_display.inventory.money -= money_trade
	
	trader_inventory_display.update_inventory();
	player_inventory_display.update_inventory();

	for i in int(sqrt(trade_volume)):
		player_inventory_display.sfx.play_sound_by_key("coin_drop");
		await get_tree().create_timer(.05).timeout;
	reset_trade_balance();
	
	Entities.player.inventory.refresh_resource_counts();
	
	player_inventory_display.set_reset_state();
	trader_inventory_display.set_reset_state();

func set_label_text(label:Label, value:int)->void:
	label.text = str(value);


func _on_exit_pressed() -> void:
	trade_finished.emit();
	queue_free();



func _on__hour_upkeep_pressed() -> void:
	var trader_food_total:int = trader_inventory_display.current_resource_amount("food")
	var trader_fuel_total:int = trader_inventory_display.current_resource_amount("fuel")
	
	var food_to_get:int = min(trader_food_total, food_hourly_cost)
	var fuel_to_get:int = min(trader_fuel_total, fuel_hourly_cost)
	
	trader_inventory_display.send_resource_by_amount("fuel", fuel_to_get)
	trader_inventory_display.send_resource_by_amount("food", food_to_get)


func _on_24_hour_upkeep_pressed() -> void:
	var trader_food_total:int = trader_inventory_display.current_resource_amount("food")
	var trader_fuel_total:int = trader_inventory_display.current_resource_amount("fuel")
	
	var food_to_get:int = min(trader_food_total, food_hourly_cost*24)
	var fuel_to_get:int = min(trader_fuel_total, fuel_hourly_cost*24)
	
	trader_inventory_display.send_resource_by_amount("food", food_to_get)
	trader_inventory_display.send_resource_by_amount("fuel", fuel_to_get)


func _on_player_inventory_display_invalid_move(_message: String, returned_item_mirror:ItemMirror=null) -> void:
	if returned_item_mirror:
		money_trade += returned_item_mirror.price;
		
	


func _on_trader_inventory_display_invalid_move(_message: String, returned_item_mirror:ItemMirror=null) -> void:
		if returned_item_mirror:
			money_trade -= returned_item_mirror.price;
