extends UIRoot;

signal settlement_entered(settlement:Settlement);
signal settlement_left;


@export var sky_props:Control;
@export var sky_bg:ColorRect;
@export var name_label:Label;
@export var short_description_label:RichTextLabel;
@export var long_description_label:RichTextLabel;

@export var trade_btn:Button;
@export var recruit_units_btn:Button;
@export var listen_around_btn:Button;

@export_subgroup("views")
@export var main_view:Control;
@export var trade_view:Control;

@export_subgroup("sounds")
@export var trade_completed_sound:AudioStream;

var sky_base_color = Color.LIGHT_SKY_BLUE;

@onready var basic_options:Array[Button] = [
	trade_btn,
	recruit_units_btn,
	listen_around_btn
]


func _on_settlement_entered(settlement: Settlement) -> void:
	Entities.main_bgm.play_bgm("in_settlement")
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
	
	sky_bg.modulate = Entities.world_map.modulate * sky_base_color;
	show();
	
	
	Tweens.ui_fade_in(self)



func _on_settlement_left() -> void:
	Entities.main_bgm.play_bgm("in_map")
	Entities.world_map.unpause_map();


func _on_trade_menu_trade_completed() -> void:
	ui_sfx.play_stream(trade_completed_sound)
