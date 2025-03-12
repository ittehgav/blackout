extends PanelContainer

@export var main_view:Control;
@export var trade_menu:Control;
@export var recruitment_menu:Control;

@onready var current_view = main_view;

func trade() -> void:
	main_view.hide();
	trade_menu.open();
	current_view = trade_menu



func recruit_units() -> void:
	pass # Replace with function body.


func listen_around() -> void:
	pass # Replace with function body.


func exit_settlement() -> void:
	var settlement_ui:Control = get_parent().get_parent();
	settlement_ui.settlement_left.emit();
	settlement_ui.hide();

func show_main_view()->void:
	trade_menu.hide()
	##item_trade_menu.hide();
	##recruitment_menu.hide()
	
	main_view.show();
	current_view = main_view;
