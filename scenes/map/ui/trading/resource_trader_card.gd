extends Panel

@export var money_amount_label:Label;
@export var food_amount_label:Label;
@export var fuel_amount_label:Label;

@export var juice_amount_label:Label;
@export var scrap_amount_label:Label;
@export var chips_amount_label:Label;

@export var food_value_label:Label;
@export var fuel_value_label:Label;

@export var juice_value_label:Label;
@export var scrap_value_label:Label;
@export var chips_value_label:Label;


@export var menu:Control;

var holder;

func update_values()->void:
	update_amount_label(money_amount_label, "money", menu.money_trade, true);
	update_amount_label(food_amount_label, "food", menu.food_trade);
	update_amount_label(fuel_amount_label, "fuel", menu.fuel_trade);

	update_amount_label(juice_amount_label, "juice", menu.juice_trade);
	update_amount_label(scrap_amount_label, "scrap", menu.scrap_trade);
	update_amount_label(chips_amount_label, "chips", menu.chips_trade);

	var new_values = menu.get_resource_values(self);

	update_value_label(food_value_label, "food", new_values["food"]);
	update_value_label(fuel_value_label, "fuel", new_values["fuel"]);

	update_value_label(juice_value_label, "juice", new_values["juice"]);
	update_value_label(scrap_value_label, "scrap", new_values["scrap"]);
	update_value_label(chips_value_label, "chips", new_values["chips"]);


func update_value_label(label:Label, resource:String, new_price)->void:
	label.text = resource + " - $" + str(snapped(new_price, .01))

func update_amount_label(label:Label, resource_key:String, trade_value:int, is_money:bool = false)->void:
	var current_resource = holder.inventory[resource_key];
	var text:String = "";
	if is_money:
		text = "$"
	text += str(current_resource);
	
	if trade_value:
		text += "-> ";
		if is_money:
			text += "$"

		var after_trade_value:int
		if holder is Player:
			after_trade_value = current_resource + trade_value
		else:
			after_trade_value = current_resource - trade_value
		text += str(after_trade_value);
		
	label.text = text;


func trade_1(resource:String)->void:
	var total:int = holder.inventory[resource]
	var traded:int = menu[resource+"_trade"];
	if holder is Player:
		total += traded
	else:
		total -= traded

	if total >= 1:
		trade_resource(resource, 1)
		menu.refresh_values();
	
func trade_10(resource:String)->void:
	var total:int = holder.inventory[resource]
	var traded:int = menu[resource + "_trade"];
	if holder is Player:
		total += traded
	else:
		total -= traded
	if total >= 10:
		trade_resource(resource, 10)
		menu.refresh_values();
	else:
		trade_max(resource);
	

	
func trade_max(resource:String)->void:
	var total = holder.inventory[resource];

	if holder is Player:
		menu[resource + "_trade"] = total * -1;
	else:
		menu[resource + "_trade"] = total;
	menu.refresh_values();

func trade_resource(resource:String, amount:int)->void:
	if holder is Player:
		menu[resource + "_trade"] -= amount;
	else:
		menu[resource + "_trade"] += amount
