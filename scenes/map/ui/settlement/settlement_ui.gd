extends UIRoot;


signal settlement_entered(settlement:Settlement);
signal settlement_left;

signal trade_started;
signal trade_finished;

signal recruitment_started;
signal recruitment_ended;

signal listen_around_started;
signal listen_around_ended;

@export var post_listen_around:Control;
@export var post_listen_around_list:VBoxContainer;
@export var memo_label:RichTextLabel;


@onready var current_view:Control = main_view;

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

@export var trade_menu:Control;
@export var recruitment_menu:Control;


var current_settlement:Settlement;

var listening_around:bool=false;


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
	
	show_main_view(true);
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
	
	sky_bg.color_background()
	Tweens.ui_fade_in(self)



func exit_settlement() -> void:
	if not listening_around:
		settlement_left.emit();
		hide();

func _on_settlement_left() -> void:
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


func listen_around() -> void:
	listen_around_started.emit()
	listening_around = true;
	sky_props.generate_sky();
	var camera_tween:Tween = create_tween();
	camera_tween.tween_property(main_view, "modulate:a", 0, .5)
	camera_tween.set_trans(Tween.TRANS_SINE)
	camera_tween.parallel().tween_property(self, "position:y", size.y/1.5, 2)
	
	await camera_tween.finished
	
	var colors:Array[Color] = [];

	
	for i in 3:
		Entities.world_map.hour_passed.emit();
		sky_bg.color_background(true);

	await get_tree().create_timer(1.5).timeout
	var crowd_tween:Tween = create_tween();
	crowd_tween.tween_property(crowd_rect, "modulate:a", 0, .15);
	crowd_tween.tween_callback(sky_bg.switch_crowd);
	crowd_tween.tween_property(crowd_rect, "modulate:a", 1, .15)
	

	for c in post_listen_around_list.get_children():
		if c.visible and c is RichTextLabel:
			c.queue_free();
	
	var all_anomalies:Array[Memo] = []
	for neighbor:Settlement in Entities.current_settlement.neighbors:
		for anomaly:TradeAnomaly in neighbor.ongoing_anomalies:
			all_anomalies.append(anomaly);

	var found:Array[Memo];
	while len(found) < 3:
		var pick:TradeAnomaly = all_anomalies.pick_random();
		if not (pick in found):
			found.append(all_anomalies.pick_random())

	for anomaly:TradeAnomaly in found:
		var label:RichTextLabel = memo_label.duplicate(true);
		label.show()
		label.text = anomaly.generate_description();
		post_listen_around_list.add_child(label);

	
	main_view.hide();
	main_view.modulate.a = 1;
	post_listen_around.modulate.a = 0;
	post_listen_around.show();
	
	var return_tween:Tween = create_tween();
	return_tween.set_trans(Tween.TRANS_CUBIC)
	return_tween.tween_property(self, "position:y", 0, 1);
	return_tween.tween_property(post_listen_around, "modulate:a", 1, 1)
	await return_tween.finished;
	listening_around = false
	listen_around_ended.emit()


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
