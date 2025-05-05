extends UIRoot;

signal settlement_entered(settlement:Settlement);
signal settlement_left;

@export var sky_props:Control;
@export var sky_bg:ColorRect;

@export var crowd_rect:TextureRect;

@export_group("settlement data")
@export var relationship_progress:ProgressBar;
@export var relation_label:RichTextLabel;
@export var name_label:Label;
@export var short_description_label:RichTextLabel;
@export var long_description_label:RichTextLabel;

@export_group("buttons")
@export var trade_btn:Button;
@export var recruit_units_btn:Button;
@export var listen_around_btn:Button;

@export_group("views")
@export var main_view:Control;
@export var trade_view:Control;

@export_group("sounds")
@export var trade_completed_sound:AudioStream;


var current_settlement:Settlement;


@onready var basic_options:Array[Button] = [
	trade_btn,
	recruit_units_btn,
	listen_around_btn
]


func _on_settlement_entered(settlement: Settlement) -> void:
	var crowd_texture:Texture =[settlement.crowd_1, settlement.crowd_2].pick_random()
	crowd_rect.texture = crowd_texture
	Entities.world_map.ui.self_modulate.a = 0
	current_settlement = settlement;
	Entities.main_bgm.play_bgm("settlement")
	ui_sfx.play_stream("settlement_entered")
	Entities.world_map.pause_map();
	
	$main_view/container/options.show_main_view();
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
	
	show();
	sky_bg.color_background()
	
	Tweens.ui_fade_in(self)




func exit_settlement() -> void:
	settlement_left.emit();
	hide();

func _on_settlement_left() -> void:
	Entities.world_map.ui.self_modulate.a = 1
	Entities.main_bgm.play_bgm("world_map")
	Entities.world_map.unpause_map();
