extends Control

@export_enum("settlement") var origin:String="settlement";

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

@export_group("traders' resoure labels")
@export var player_money_label:Label;
@export var player_food_label:Label;
@export var player_fuel_label:Label

@export var player_juice_label:Label;
@export var player_scrap_label:Label;
@export var player_chips_label:Label;

@export var trader_money_label:Label;
@export var trader_food_label:Label;
@export var trader_fuel_label:Label

@export var trader_juice_label:Label;
@export var trader_scrap_label:Label;
@export var trader_chips_label:Label;

func start_trade(target:MapEntity)->void:
	## initiation routines require both inventories to be assigned
	player_name_label.text = Entities.player.name;
	trader_name_label.text = target.name;
	
	player_inventory_display.current_inventory = Entities.player.inventory;
	trader_inventory_display.current_inventory = target.inventory;

	Entities.current_trading_party = target;
	player_inventory_display.set_grid()
	player_inventory_display.refresh_data(true);
	
	target.inventory.sort_items();
	trader_inventory_display.set_grid();
	trader_inventory_display.refresh_data(true);
	
	reset_trade_balance()
	
	for r:String in Index.all_resources:
		self[r + "_trade_label"].visible = player_inventory_display[r + "_hbox"].visible;

func refresh_trade_balance()->void:
	confirm_btn.disabled = false;
	money_trade = non_resource_money_trade;
	trade_volume = money_trade;


	reset_btn.disabled = true;

	for r:String in Index.all_resources.filter(func(r:String)->bool:return r != "money"):
		var trade:int = self[r+"_trade"]
		if trade < 0:
			## TRADE < 0 = PLAYER SELLING
			reset_btn.disabled = false
			var value:int = trader_inventory_display.current_inventory.resource_selling_prices[r] * trade
			money_trade += value;
			trade_volume += value;
		else:
			reset_btn.disabled = false;
			var value:int =trader_inventory_display.current_inventory.resource_buying_prices[r] * trade
			money_trade -= value;

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
				label.modulate = Color.GREEN;
			else:
				## TRADE < 0 = PLAYER SELLING
				label.text = str(trade * -1);
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT;
				label.modulate = Color.YELLOW;
				
	if trader_inventory_display.current_inventory.money < money_trade or\
	player_inventory_display.current_inventory.money < money_trade * -1:
		confirm_btn.disabled = true;
		money_trade_label.add_theme_color_override("font_color", Color.GRAY.darkened(.5));
	else:
		money_trade_label.add_theme_color_override("font_color", Index.resource_colors["money"]);
	


func _on_trader_inventory_display_item_dropped(mirror:ItemMirror, from:String="move") -> void:
	## ITEM DROPPED IN TRADER INVENTORY = SOLD
	if from == "trade":
		if mirror.item is ResourceContainer:
			## mirror that ends up here will have the stack size of the resource that was traded
			self[mirror.item.resource + "_trade"] -= mirror.item.stack_size - mirror.traded_resource_amount;
		else:
			non_resource_money_trade += mirror.price;
			
		refresh_trade_balance()


func _on_player_inventory_display_item_dropped(mirror:ItemMirror, from:String="move") -> void:
	## ITEM DROPPED IN PLAYER INVENTORY = BOUGHT
	if from == "trade":
		if mirror.item is ResourceContainer:
			## mirror that ends up here will have the stack size of the resource that was traded
			## READS FROM THE RESOURCES IN THE TRADE INVENTORY DISPLAYS RATHER THAN THE COUNT ON THE INVENTORIES
			self[mirror.item.resource + "_trade"] += mirror.item.stack_size - mirror.traded_resource_amount;
		else:
			non_resource_money_trade -= mirror.price;

		
		refresh_trade_balance()
		


func _on_confirm_pressed() -> void:
	finish_trade();


func _on_reset_pressed() -> void:
	player_inventory_display.refresh_data(true)
	trader_inventory_display.refresh_data(true)
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
			var trade_label_tween:Tween = create_tween();
			var player_label_tween:Tween = create_tween();
			var trader_label_tween:Tween = create_tween();
			
			for tween:Tween in [trade_label_tween, player_label_tween, trader_label_tween]:
				tween.set_ease(Tween.EASE_OUT);
				tween.set_trans(Tween.TRANS_QUINT)
			
			var player_value_label:Label = self["player_" + r + "_label"];
			var trader_value_label:Label = self["trader_" + r + "_label"];
			var trade_label:Label = self[r+"_trade_label"];
			
		
			
			var player_after:int = player_inventory_display.current_inventory[r] + self[r+"_trade"]
		
			var trader_after:int = trader_inventory_display.current_inventory[r] - self[r+"_trade"]
			
			trade_label_tween.tween_property(trade_label, "text", str(0), tween_duration)
			trade_label_tween.tween_callback(trade_label.set_text.bind(""))
			
			player_inventory_display.current_inventory[r] += trade
			trader_inventory_display.current_inventory[r] -= trade
			
			player_label_tween.tween_property(player_value_label, "text", str(player_after), tween_duration);
			trader_label_tween.tween_property(trader_value_label, "text", str(trader_after), tween_duration);
	
	player_inventory_display.update_inventory();
	trader_inventory_display.sort_inventory();
	
	for i in int(sqrt(trade_volume)):
		player_inventory_display.sfx.play_sound_by_key("coin_drop");
		await get_tree().create_timer(.05).timeout;
	reset_trade_balance();

func set_label_text(label:Label, value:int)->void:
	label.text = str(value);


func _on_exit_pressed() -> void:
	if origin == "settlement":
		var settlement_ui:UIRoot = get_parent()
		settlement_ui.show_main_view();
		settlement_ui.trade_finished.emit();
