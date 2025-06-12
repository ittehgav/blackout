extends Control

signal operation_finished;

@export var display:InventoryDisplay;
@export var trade_menu:Control

var choice_1_value:int = 1;
@export var choice_1_label:Label;

var choice_2_value:int;
@export var choice_2_label:Label;

var choice_3_value:int;
@export var choice_3_label:Label;


var current_mirror:ItemMirror;

var current_choice:Button;

var current_resource:String;

func _ready()->void:
	set_process_input(false)

func show_picker(mirror:ItemMirror)->void:
	current_mirror = mirror;
	current_resource = mirror.item.resource
	set_process_input(true)


	for label:Label in [choice_1_label, choice_2_label, choice_3_label]:
		label.add_theme_color_override("font_color", Index.get_color(mirror.item.resource))
	global_position = get_global_mouse_position()
	Tweens.ui_fade_in(self);
	
	
	var total:int = display.inventory[current_resource];
	
	var resource_trade:int = trade_menu[current_resource+"_trade"];
	if display.from_player:
		total += resource_trade;
	else:
		total -= resource_trade

	var text:String;
	
	if display.from_player:
		text = "SELL\n"
	else:
		text = "BUY\n"
	
	choice_1_label.text = text + "1";
	
	choice_2_label.text = text + str(int(total/2));
	choice_2_value = int(total/2)
	
	choice_3_label.text = text + str(total)
	choice_3_value = total
	


func _on_choice_1_pressed() -> void:
	display.send_resource(current_mirror, 1)
	hide()

func _on_choice_2_pressed() -> void:
	display.send_resource(current_mirror, choice_2_value)
	hide()


func _on_choice_3_pressed() -> void:
	display.send_resource(current_mirror, choice_3_value)
	hide()






func _on_mouse_exited() -> void:
	Tweens.ui_fade_out(self)
