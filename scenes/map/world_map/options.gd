extends PanelContainer

@export var main_view:Control;
@export var resource_trade_menu:Control;
@export var item_trade_menu:Control;
@export var recruitment_menu:Control;

@onready var current_view = main_view;

func trade_resources() -> void:
	main_view.hide();
	resource_trade_menu.open();
	current_view = resource_trade_menu


func trade_items() -> void:
	pass # Replace with function body.


func recruit_units() -> void:
	pass # Replace with function body.


func listen_around() -> void:
	pass # Replace with function body.


func exit_settlement() -> void:
	get_parent().get_parent().hide();
	Entities.in_map_player.in_settlement = false;

func show_main_view()->void:
	resource_trade_menu.hide()
	##item_trade_menu.hide();
	##recruitment_menu.hide()
	
	main_view.show();
	current_view = main_view;

func _input(e:InputEvent)->void:
	if e.is_action_pressed("ui_exit", false):
		if main_view.visible:
			exit_settlement();
		else:
			show_main_view();


func trade_1(extra_arg_0: String) -> void:
	pass # Replace with function body.
