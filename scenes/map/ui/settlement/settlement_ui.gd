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
var sky_base_color:Color = Color.LIGHT_SKY_BLUE;

@onready var basic_options:Array[Button] = [
	trade_btn,
	recruit_units_btn,
	listen_around_btn
]


func _on_settlement_entered(settlement: Settlement) -> void:
	color_bg();
	var crowd_texture:Texture =[settlement.crowd_1, settlement.crowd_2].pick_random()
	crowd_rect.texture = crowd_texture
	Entities.world_map.ui.self_modulate.a = 0
	current_settlement = settlement;
	Entities.main_bgm.play_bgm("in_settlement")
	ui_sfx.play_stream("settlement_entered")
	Entities.world_map.pause_map();
	
	$main_view/container/options.show_main_view();
	modulate.a = .1;
	$background.texture = settlement.background;

	name_label.text = settlement.name;
	short_description_label.text = settlement.description;
	long_description_label.text = settlement.flavor;
	refresh_data()
	

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

func color_bg()->void:
	var sky_color:Color = Entities.world_map.get_hour_sky_color();
	
	var prop_opaque_color:Color;
	var prop_reflective_color:Color;
	
	var ground_opaque_color:Color;
	var ground_reflective_color:Color;
	
	if Entities.world_map.current_hour >= 20 or Entities.world_map.current_hour <= 4:
		prop_reflective_color = sky_color.lightened(.3);
		prop_opaque_color = Color.MIDNIGHT_BLUE.lightened(.2);
		
		ground_reflective_color = Color.MIDNIGHT_BLUE.darkened(.3)
		ground_opaque_color = Color.SANDY_BROWN.blend(Color.MIDNIGHT_BLUE);
		
	else:
		prop_reflective_color = sky_color.blend(Color.YELLOW.darkened(.2) - Color(0, 0, 0, .3));
		prop_opaque_color = Color.GOLDENROD.darkened(.8);
		
		ground_reflective_color = Color(223.0/255, 134.0/255, 76.0/255).blend(sky_color.darkened(.5) - Color(0, 0, 0, .7))
		ground_opaque_color = Color(100.0/255, 16.0/255, 14.0/255).darkened(.1)

	$background.material.set_shader_parameter("prop_reflective", prop_reflective_color)
	$background.material.set_shader_parameter("prop_opaque", prop_opaque_color)
	
	$background.material.set_shader_parameter("ground_reflective", ground_reflective_color)
	$background.material.set_shader_parameter("ground_opaque", ground_opaque_color)
	 

func refresh_data()->void:
	relation_label.text = "Relation: " + current_settlement.relation_level_string()
	relationship_progress.max_value = current_settlement.relation_progress_for_next_level()
	relationship_progress.value = current_settlement.relation_progress;


func exit_settlement() -> void:
	settlement_left.emit();
	hide();

func _on_settlement_left() -> void:
	Entities.world_map.ui.self_modulate.a = 1
	Entities.main_bgm.play_bgm("in_map")
	Entities.world_map.unpause_map();
	breakpoint


func _on_trade_menu_trade_completed() -> void:
	ui_sfx.play_stream_obj(trade_completed_sound)
