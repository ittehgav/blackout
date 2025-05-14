extends Control

signal operation_finished;

@export var display:InventoryDisplay;
@export var trade_menu:Control

var choice_1_value:int = 1;
@export var choice_1:ColorRect;
@export var choice_1_label:Label;

var choice_2_value:int;
@export var choice_2:ColorRect
@export var choice_2_label:Label;

var choice_3_value:int;
@export var choice_3:ColorRect
@export var choice_3_label:Label;

@onready var choices_initial_size:Vector2 = choice_1.custom_minimum_size;

var current_choice:ColorRect;

var current_resource:String;

func _ready()->void:
	set_process_input(false)

func show_picker(resource:String)->void:
	set_process_input(true)
	current_resource = resource;
	show()
	modulate = Index.resource_colors[resource]
	global_position = get_global_mouse_position()
	Tweens.ui_fade_in(self, 1);
	
	
	var total:int = display.current_inventory[resource];
	
	var resource_trade:int = trade_menu[resource+"_trade"];
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
	
	expose_choice(choice_1);

func expose_choice(choice:ColorRect)->void:
	current_choice = choice;
	var tween:Tween = create_tween();
	tween.tween_property(choice, "custom_minimum_size", choices_initial_size * 1.5, .2);
	tween.parallel().tween_property(choice, "color:a", 1, .1)

func unexpose_choice(choice:ColorRect)->void:
	var tween:Tween = create_tween();
	tween.tween_property(choice, "custom_minimum_size", choices_initial_size, .1);
	tween.parallel().tween_property(choice, "color:a", .5, .1)


func _on_choice_1_mouse_entered() -> void:
	expose_choice(choice_1)
func _on_choice_1_mouse_exited() -> void:
	unexpose_choice(choice_1)

func _on_choice_2_mouse_entered() -> void:
	expose_choice(choice_2)
func _on_choice_2_mouse_exited() -> void:
	unexpose_choice(choice_2)

func _on_choice_3_mouse_entered() -> void:
	expose_choice(choice_3)
func _on_choice_3_mouse_exited() -> void:
	unexpose_choice(choice_3)


func pick_choice()->void:
	match current_choice:
		choice_1:
			display.trade_resource(current_resource, choice_1_value);
		choice_2:
			display.trade_resource(current_resource, choice_2_value)
		choice_3:
			display.trade_resource(current_resource, choice_3_value)
	set_process_input(false);
	hide();

func _input(e:InputEvent)->void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_RIGHT and not e.pressed:
		pick_choice()
