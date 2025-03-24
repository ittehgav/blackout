extends Control

signal trade_completed;

var player:Leader;
var settlement:Settlement;

## money trade shows separately
var money_trade:float=0;
## trade volume is used to calculate relation points gained from trade
var trade_volume:float=0;

## trade value is the change that will occur in the player's inventory
## if the trade occurs
##  positive if the resource is being bought and negative if sold


var food_trade:int=0;
var fuel_trade:int=0;

var juice_trade:int=0;
var scrap_trade:int=0;
var chips_trade:int=0;

const all_trade_resources = ["food", "fuel", "juice", "scrap", "chips"];

@export_subgroup("middle panel elements")
@export var relation_progress_current:ProgressBar;
@export var relation_progress_gain:ProgressBar;
@export var relation_label:RichTextLabel;

@export var in_trade_view:Panel;
@export var reset_btn:Button;
@export var confirm_btn:Button;

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
@export var money_trade_display:HBoxContainer;

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

var relation_glow:bool = false;

## TODO: the player can buy supplies in days/hours worth of upkeep for their current party
func open()->void:
	player_money.text = str(Entities.player.inventory.money);
	settlement_money.text= str(Entities.current_settlement.inventory.money)
	player = Entities.in_map_player.leader;
	settlement = Entities.current_settlement;
	
	relation_label.text = "Relation: " + settlement.relation_level_string();
	
	relation_progress_current.max_value = settlement.relation_progress_for_next_level();
	relation_progress_gain.max_value = settlement.relation_progress_for_next_level();
	
	relation_progress_current.value = settlement.relation_progress
	relation_progress_gain.value = settlement.relation_progress
	
	for r in all_trade_resources:
		self[r + "_trade"] = 0;
	
	slide_in();
		
	update_values();
	show()
	

func slide_in():
	position.y = 800;
	var hbox:HBoxContainer = $margin/hbox;
	hbox.add_theme_constant_override("separation", 1000);
	var tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", 0, .25);
	tween.parallel().tween_property(hbox, "theme_override_constants/separation", 50, .25)
	

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
	trade_volume = 0;
	if visible:
		const shake_range = 10;
		var x_roll = randi_range(shake_range * -1, shake_range);
		var y_roll = randi_range(shake_range * -1, shake_range);
		in_trade_view.position = Vector2(x_roll, y_roll)

		var tween = create_tween();
		tween.set_trans(Tween.TRANS_BOUNCE);
		tween.tween_property(in_trade_view, "position", Vector2.ZERO, .15)

	money_trade = 0;
	reset_btn.hide()
	player_money.modulate = Color.WHITE;
	settlement_money.modulate = Color.WHITE;
	for resource in all_trade_resources:
		self[resource + "_selling_price"].text = str( settlement.resource_prices[resource]/2); 
		self[resource + "_buying_price"].text = str( settlement.resource_prices[resource]*2); 
		
		var traded = self[resource+"_trade"]
		
		var trade_display = self[resource+"_trade_display"]
		
		var player_current = Entities.player.inventory[resource];
		var settlement_current = Entities.current_settlement.inventory[resource];
		
		if traded:
			reset_btn.show();
			trade_display.show()
			self["player_" + resource].text = str(player_current) + "->" + str(player_current + traded);
			self["settlement_" + resource].text = str(settlement_current) + "->" + str(settlement_current - traded)
			
			var sold_label = trade_display.get_node("sold");
			var bought_label = trade_display.get_node("bought");
			
			if traded > 0:
				## trade of an item > 0 = player buying
				## player buying = money trade go down
				## RESOURCE BUYING PRICE = PLAYER BUYING
				var trade = traded * settlement.resource_buying_prices[resource];
				money_trade -= trade;
				trade_volume += trade
				
				bought_label.show()
				bought_label.text = str(traded)
				sold_label.hide();
			else:
				## trade of an item < 0 = player selling
				## player selling = money trade go up
				## RESOURCE SELLING PRICE = PLAYER SELLING
				var trade = traded * settlement.resource_selling_prices[resource] * -1
				money_trade += trade;
				trade_volume += trade;
				sold_label.show()
				sold_label.text = str(abs(traded));
				bought_label.hide();
		else:
			self["player_" + resource].text = str(player_current)
			self["settlement_" + resource].text = str(settlement_current)
			trade_display.hide()

	if trade_volume:
		var player_can_pay:bool =  Entities.player.inventory.money > money_trade * -1;
		var settlement_can_pay:bool = settlement.inventory.money > money_trade;
		if player_can_pay and settlement_can_pay:
			confirm_btn.disabled = false;
		else:
			confirm_btn.disabled = true;
			if not player_can_pay:
				player_money.modulate = Color.RED;
			else:
				settlement_money.modulate = Color.RED;
		
			
		money_trade_display.show()
		if money_trade >= 0:
			money_trade_display.alignment = BoxContainer.ALIGNMENT_BEGIN
			money_trade_display.get_node("label").modulate = Color.GREEN;
			money_trade_display.get_node("label").text = str(abs(money_trade));
		else:
			money_trade_display.alignment = BoxContainer.ALIGNMENT_END
			money_trade_display.get_node("label").modulate = Color.GOLD;
			money_trade_display.get_node("label").text =  str(abs(money_trade));
	else:
		confirm_btn.disabled = true;
		money_trade_display.hide();
	
	var relation_gain = trade_volume / 100;
	relation_progress_gain.value = settlement.relation_progress + relation_gain;
	if relation_progress_gain.value >= relation_progress_gain.max_value:
		relation_glow = true;
		relation_level_glow();
	else:
		relation_glow=false



func reset_trade() -> void:
	for r in all_trade_resources:
		self[r + "_trade"] = 0;
	update_values()
	


func _on_confirm_trade_pressed() -> void:
	for r in ["food", "fuel", "money", "juice", "scrap", "chips"]:
		var trade = self[r+"_trade"];
		Entities.player.inventory[r] += trade;
		settlement.inventory[r] -= trade
		
	Entities.player.resources_changed.emit();
	trade_completed.emit();
	
	settlement.gain_relation_progress(trade_volume/100)
	
	exit_trade_menu()


func exit_trade_menu() -> void:
	hide();
	get_parent().refresh_data();
	var main_view = get_parent().main_view;
	var tween = create_tween();
	tween.tween_property(main_view, "modulate:a", 1, .25)
	main_view.show();
	
func relation_level_glow():
	if relation_glow:
		var tween = create_tween();
		tween.tween_property(relation_progress_gain, "self_modulate:a", .3, .5);
		tween.tween_property(relation_progress_gain, "self_modulate:a", 1, .5);
		tween.tween_callback(relation_level_glow)
