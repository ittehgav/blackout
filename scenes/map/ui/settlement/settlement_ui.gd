extends UIRoot;



signal trade_started;
signal trade_finished;

signal recruitment_started;
signal recruitment_ended;

signal listen_around_started;
signal listen_around_ended;

@export var overlay:CanvasLayer

@onready var current_view:Control = main_view;

@export var sky_props:Control;
@export var sky_bg:ColorRect;

@export var crowd_rect:TextureRect;

@export_group("settlement data")
@export var relationship_progress:ProgressBar;
@export var relation_label:RichTextLabel;
@export var name_label:Label;
@export var settlement_type_label:Label;
@export var short_description_label:RichTextLabel;
@export var long_description_label:RichTextLabel;

@export var anomaly_resource_icon:ResourceIcon;
@export var anomaly_arrows:Array[TextureRect]
@export var anomaly_sign:Label;

@export_group("buttons")
@export var trade_btn:Button;
@export var recruit_units_btn:Button;
@export var listen_around_btn:Button;
@export var local_event_btn:Button;

@export var local_event_btn_label:RichTextLabel;

@export_group("views")
@export var main_view:Control;

@export var trade_menu:Control;
@export var recruitment_menu:Control;
@export var event_view:Control;

var current_settlement:Settlement;

var listening_around:bool=false;



@onready var basic_options:Array[Button] = [
	trade_btn,
	recruit_units_btn,
	listen_around_btn,
	local_event_btn
]


func _on_settlement_entered(settlement: Settlement) -> void:
	overlay.layer += 1
	var anomaly:TradeAnomaly = settlement.ongoing_trade_anomaly;
	anomaly_resource_icon.resource = anomaly.resource;
	anomaly_resource_icon.setup();
	
	if anomaly.positive:
		## ARROW DOWN = PRICE DOWN = STOCK UP
		anomaly_sign.add_theme_color_override("font_color", Color.RED)
		for arrow in anomaly_arrows:
			arrow.flip_v = true
			arrow.modulate = Color.GREEN
	else:
		## ARROW UP = PRICE UP = STOCK DOWN
		anomaly_sign.add_theme_color_override("font_color", Color.GREEN)
		for arrow in anomaly_arrows:
			arrow.flip_v = false
			arrow.modulate = Color.RED;
			
	var breakpoints:Array[float]  = TradeAnomaly.intensity_breakpoints;
	if anomaly.change < breakpoints[0]:
		anomaly_arrows[0].show()
		anomaly_arrows[1].hide()
		anomaly_arrows[2].hide()
	elif anomaly.change < breakpoints[1]:
		anomaly_arrows[0].show()
		anomaly_arrows[1].show()
		anomaly_arrows[2].hide()
	else:
		anomaly_arrows[0].show()
		anomaly_arrows[1].show()
		anomaly_arrows[2].show()
	
	settlement.player_inside = true;
	
	var crowd_texture:Texture = [settlement.crowd_1, settlement.crowd_2].pick_random()
	crowd_rect.texture = crowd_texture
	Entities.world_map.ui.self_modulate.a = 0
	current_settlement = settlement;
	Entities.main_bgm.play_bgm("settlement")
	ui_sfx.play_stream("settlement_entered")
	Entities.world_map.pause_map();
	
	show_main_view(true);
	modulate.a = .1;
	$background.texture = settlement.background;

	name_label.text = settlement.name;
	settlement_type_label.text = settlement.settlement_type_name
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
	if settlement.local_event:
		setup_local_event();
	
	sky_bg.color_background()
	Tweens.ui_fade_in(self)

	
 
func exit_settlement() -> void:
	overlay.layer -= 1;
	if not listening_around:
		Entities.player.left_settlement.emit();
		hide();


func _on_player_left_settlement() -> void:
	Entities.current_settlement = null;
	current_settlement.player_inside = false;
	Entities.world_map.ui.self_modulate.a = 1
	Entities.main_bgm.play_bgm("world_map")
	
	Entities.world_map.unpause_map();


func trade() -> void:
	trade_started.emit()
	
	var tween:Tween = Tweens.ui_fade_out(main_view, true, .25);
	tween.tween_callback(Tweens.ui_fade_in.bind(trade_menu, .25));
	trade_menu.start_trade(current_settlement)
	current_view = trade_menu


func recruit_units() -> void:
	recruitment_started.emit()
	var tween:Tween = Tweens.ui_fade_out(main_view, true, .25);
	tween.tween_callback(recruitment_menu.show)
	tween.tween_callback(Tweens.ui_fade_in.bind(recruitment_menu, .25));
	current_view = recruitment_menu
	
	recruitment_menu.start();





func show_main_view(just_entered:bool=false)->void:
	if not just_entered:
		var fade:Tween = Tweens.ui_fade_out(current_view, true, .25);
		fade.tween_callback(main_view.show)
		fade.tween_callback(Tweens.ui_fade_in.bind(main_view, .25));

		
		current_view = main_view;
	else:
		trade_menu.hide();
		recruitment_menu.hide();
		main_view.show()
		Tweens.ui_fade_in(main_view, .25)


func setup_local_event()->void:
	var event:LocalEvent = current_settlement.local_event;
	event_view.setup_event_confirmation(event)
	
	local_event_btn.disabled = true;
	local_event_btn_label.text = event.final_action_prompt;
	local_event_btn_label.modulate.a = .5;
	
	for unit:FighterUnit in Entities.player.roster.units:
		if event.tag in unit.base.tags:
			local_event_btn.disabled = false;
			local_event_btn_label.modulate.a = 1;

	local_event_btn.show();

func _on_local_event_pressed() -> void:
	Tweens.ui_fade_out(main_view, true, .25);
	Tweens.ui_fade_in(event_view);
	
	current_view = event_view;
