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

@export var player_resources_dropdown:ResourcesDropdown;
@export var trader_resourcs_dropdown:ResourcesDropdown

var trade_volume:int = 0;
@export var exit_prompt:ColorRect


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

var player_inventory:Inventory
var trader_inventory:ShopInventory;

var initial_player_inventory:Inventory
var initial_trader_inventory:Inventory;


func start_trade(target:Inventory, target_name:String)->void:
	Entities.main.set_substate("trade")
	## initiation routines require both inventories to be assigned
	player_name_label.text = Entities.player.name;
	trader_name_label.text = target_name
	
	player_inventory = Entities.player.inventory
	trader_inventory = target
	## needs to load trader first because buying/selling prices are defined by the NPC
	

	trader_inventory_display.inventory = trader_inventory
	trader_inventory_display.opened.emit()
	
	player_inventory_display.inventory = player_inventory
	player_inventory_display.opened.emit()
	set_reset_state()
	
	## re-refreshing to make them account for eachother 
	## when setting up th resource dropdowns
	player_inventory_display.refresh_data()
	trader_inventory_display.refresh_data()

	
	refresh_trade_balance()
	player_inventory_display.warnings_popup.hide();
	
	trade_started.emit();

	var upkeep_cost:Dictionary = Entities.player.travel_upkeep_cost();
	food_hourly_cost = upkeep_cost.food * 3;
	fuel_hourly_cost = upkeep_cost.fuel * 3;
	
	food_hourly_cost_label.text = str(food_hourly_cost)
	food_daily_cost_label.text = str(food_hourly_cost * 24)
	
	fuel_hourly_cost_label.text = str(fuel_hourly_cost)
	fuel_daily_cost_label.text = str(fuel_hourly_cost * 24)
	
func set_reset_state()->void:
	initial_trader_inventory = trader_inventory_display.set_reset_state()
	initial_player_inventory = player_inventory_display.set_reset_state()
	
	

func refresh_trade_balance()->void:
	confirm_btn.disabled = false;
	money_trade = 0
	trade_volume = 0


	reset_btn.disabled = true;
	
	var resources:Array = Index.all_resources.filter(func(r:String)->bool:return r != "money")
	for r:String in resources:
		## POSITIVE DELTA = SOURCE GAINED RESOURCE
		var player_delta:int = Entities.player.inventory[r]-initial_player_inventory[r]  
		var trader_delta:int = trader_inventory_display.inventory[r] - initial_trader_inventory[r]
		assert(player_delta == -trader_delta);
		self[r+"_trade"] = player_delta;
	
	var sold_items:Array[Item];
	var bought_items:Array[Item]
	for item:Item in initial_player_inventory.items:
		if item not in player_inventory.items:
			sold_items.append(item)

	for item:Item in initial_trader_inventory.items:
		if item not in trader_inventory.items:
			bought_items.append(item);

	for item:Item in bought_items:
		var value:int = item.get_price() * trader_inventory.buying_prices_multiplier;
		money_trade -= value
		trade_volume += abs(value)
		
	for item:Item in sold_items:
		var value:int = item.get_price() / trader_inventory.selling_prices_divider
		money_trade += value
		trade_volume += abs(value)
	
	if len(sold_items) or len(bought_items):
		reset_btn.disabled = false
	
	
	for r:String in resources:
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
		
		var trade:int= self[r + "_trade"]

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
	




func _on_trader_inventory_display_item_received() -> void:
	## ITEM DROPPED IN TRADER INVENTORY = SOLD
	refresh_trade_balance()


func _on_player_inventory_display_item_received() -> void:
	## ITEM DROPPED IN PLAYER INVENTORY = BOUGHT
	refresh_trade_balance()


func _on_confirm_pressed() -> void:
	if player_inventory_display.pending_warnings():
		player_inventory_display.warn_player();
		var clear:bool = await player_inventory_display.warnings_attended;
		if clear:
			finish_trade();
	else:
		finish_trade();


func reset_trade() -> void:
	player_inventory_display.reset_inventory();
	trader_inventory_display.reset_inventory();
	
	player_resources_dropdown.update();
	trader_resourcs_dropdown.update()
	
	set_reset_state()
	refresh_trade_balance()
	
	player_inventory_display.sfx.play_sound_by_key("reset");




func finish_trade()->void:
	const tween_duration = 1.25
	Entities.main.revert_substate()
	for r:String in Index.all_resources:
		var trade:int = self[r+"_trade"];
		if trade:
			var tween:Tween = create_tween();
			
			tween.set_ease(Tween.EASE_OUT);
			tween.set_trans(Tween.TRANS_QUINT)

			var trade_label:Label = self[r+"_trade_label"];

			tween.tween_property(trade_label, "text", str(0), tween_duration)
			tween.tween_callback(trade_label.set_text.bind(""))
	
	trade_finished_sfx()

	
	player_inventory.money += money_trade;
	trader_inventory.money -= money_trade
	
	player_resources_dropdown.update([trader_inventory], true);
	trader_resourcs_dropdown.update([player_inventory], true)
	
	if money_trade:
		Entities.player.resource_changed.emit.call_deferred("money")
	
	set_reset_state();
	player_inventory_display.hard_reset()
	trader_inventory_display.hard_reset()
	refresh_trade_balance()


func trade_finished_sfx()->void:
	trader_inventory_display.sfx.play_sound_by_key("money_change")
	for i in int(sqrt(abs(trade_volume))):
		player_inventory_display.sfx.play_sound_by_key("coin_drop");
		await get_tree().create_timer(.05).timeout;


func set_label_text(label:Label, value:int)->void:
	label.text = str(value);



func _on_exit_pressed() -> void:
	if not reset_btn.disabled:
		show_exit_prompt();
	else:
		trade_finished.emit();
		queue_free();

func show_exit_prompt()->void:
	Tweens.ui_fade_in(exit_prompt)

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


func _on_trader_inventory_display_invalid_move(_message: String, returned_item_mirror:ItemMirror=null) -> void:
		if returned_item_mirror:
			money_trade -= returned_item_mirror.price;


var just_refreshed:bool=false
func _on_player_inventory_display_item_dropped(_mirror: ItemMirror) -> void:
	if not just_refreshed:
		refresh_trade_balance()
		just_refreshed = true;
		await get_tree().create_timer(.1).timeout;
		just_refreshed = false


func _on_trader_inventory_display_item_dropped(_mirror: ItemMirror) -> void:
	if not just_refreshed:
		refresh_trade_balance()
		just_refreshed = true;
		await get_tree().create_timer(.1).timeout;
		just_refreshed = false


func _on_reset_and_exit_pressed() -> void:
	reset_trade();
	trade_finished.emit()
	await Tweens.ui_fade_out(self).finished;
	queue_free();
	

func _on_return_pressed() -> void:
	Tweens.ui_fade_out(exit_prompt)
