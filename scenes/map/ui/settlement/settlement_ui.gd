extends UIRoot;

signal settlement_entered(settlement:Settlement);
signal settlement_left;

@export var sky_bg:ColorRect;
@export var name_label:Label;
@export var short_description_label:RichTextLabel;
@export var long_description_label:RichTextLabel;

@export var trade_btn:Button;
@export var recruit_units_btn:Button;
@export var listen_around_btn:Button;



@onready var basic_options:Array[Button] = [
	trade_btn,
	recruit_units_btn,
	listen_around_btn
]


func _on_settlement_entered(settlement: Settlement) -> void:
	ui_sfx.play_stream(ui_sfx.settlement_entered)
	Entities.world_map.pause_map();
	
	$main_view/options.show_main_view();
	modulate.a = .1;
	$background.texture = settlement.background;

	name_label.text = settlement.name;
	short_description_label.text = settlement.description;
	long_description_label.text = settlement.flavor;
	
	for button:Button in basic_options:
		button.hide();

	if settlement.trade:
		trade_btn.show();
	if settlement.recruit_units:
		recruit_units_btn.show();
	if settlement.listen_around:
		listen_around_btn.show();
	
	sky_bg.modulate = Entities.world_map.ambient_light.color;
	show();
	
	
	Tweens.ui_fade_in(self)



func _on_settlement_left() -> void:
	Entities.world_map.unpause_map();
