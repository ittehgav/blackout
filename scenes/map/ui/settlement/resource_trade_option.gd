extends HBoxContainer

@export var trade_menu:Control;
@export var player_side:bool=true;

var resource:String;

var plus_one_btn:Button;
var plus_ten_btn:Button;
var max_btn:Button;

func _ready()->void:
	resource = get_child(0).resource;
	plus_one_btn = $Button;
	plus_ten_btn = $Button2;
	max_btn = $Button3;
	
	plus_one_btn.pressed.connect(trade_one);
	plus_ten_btn.pressed.connect(trade_10);
	max_btn.pressed.connect(trade_max)
	

func trade_one()->void:
	var change:float = 1;
	if player_side:
		change *= -1;
	trade_menu[resource+"_trade"] += change;
	trade_menu.update_values()
	
func trade_10()->void:
	var change:float = 10;
	if player_side:
		change *= -1;
	trade_menu[resource+"_trade"] += change;
	trade_menu.update_values()

func trade_max()->void:
	var change:float;
	if player_side:
		change = -Entities.player.inventory[resource];
	else:
		change = Entities.current_settlement.inventory[resource];
	trade_menu[resource+"_trade"] = change;
	trade_menu.update_values()
