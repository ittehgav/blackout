extends Control

@warning_ignore("unused_signal")
signal settlement_entered;
@warning_ignore("unused_signal")
signal settlement_left;

@export var name_label:Label;
@export var short_description_label:RichTextLabel;
@export var long_description_label:RichTextLabel;

@export var trade_resources_btn:Button;
@export var trade_items_btn:Button;
@export var recruit_units_btn:Button;
@export var listen_around_btn:Button;



@onready var basic_options:Array[Button] = [
	trade_resources_btn,
	trade_items_btn,
	recruit_units_btn,
	listen_around_btn
]


func _on_player_settlement_entered(settlement: Settlement) -> void:
	$main_view/options.show_main_view();
	
	modulate.a = .1;
	$background.texture = settlement.background;

	name_label.text = settlement.name;
	short_description_label.text = settlement.short_description;
	long_description_label.text = settlement.description;
	
	for button:Button in basic_options:
		button.hide();

	if settlement.settings.trade_resources:
		trade_resources_btn.show();
	if settlement.settings.trade_items:
		trade_items_btn.show();
	if settlement.settings.recruit_units:
		recruit_units_btn.show();
	if settlement.settings.listen_around:
		listen_around_btn.show();
		
	show();
	
	var tween = create_tween();
	tween.tween_property(self, "modulate:a", 1, .5);
