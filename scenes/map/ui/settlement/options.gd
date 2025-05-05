extends PanelContainer

@export var settlement_ui:UIRoot;

@export var post_listen_around:Control;
@export var post_listen_around_list:VBoxContainer;
@export var memo_label:RichTextLabel;

@export var main_view:Control;
@export var trade_menu:Control;
@export var recruitment_menu:Control;

@onready var current_view:Control = main_view;

func trade() -> void:
	var tween:Tween = Tweens.ui_fade_out(main_view, .25);
	tween.tween_callback(main_view.hide);
	tween.tween_callback(trade_menu.show)
	tween.tween_callback(Tweens.ui_fade_in.bind(trade_menu));
	trade_menu.start_trade(settlement_ui.current_settlement)
	current_view = trade_menu



func recruit_units() -> void:
	pass # Replace with function body.


func listen_around() -> void:
	settlement_ui.sky_props.generate_sky();
	var camera_tween:Tween = create_tween();
	camera_tween.tween_property(main_view, "modulate:a", 0, .5)
	camera_tween.set_trans(Tween.TRANS_SINE)
	camera_tween.parallel().tween_property(settlement_ui, "position:y", settlement_ui.size.y/1.5, 2)
	
	await camera_tween.finished
	
	var colors:Array[Color] = [];

	var sky_tween:Tween = create_tween();
	
	for i in 3:
		Entities.world_map.hour_passed.emit();
		settlement_ui.sky_bg.color_background(true);

	await get_tree().create_timer(1.5).timeout
	var crowd_tween = create_tween();
	crowd_tween.tween_property(settlement_ui.crowd_rect, "modulate:a", 0, .15);
	crowd_tween.tween_callback(settlement_ui.sky_bg.switch_crowd);
	crowd_tween.tween_property(settlement_ui.crowd_rect, "modulate:a", 1, .15)
	

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
	return_tween.tween_property(settlement_ui, "position:y", 0, 1);
	return_tween.tween_property(post_listen_around, "modulate:a", 1, 1)


func show_main_view()->void:
	trade_menu.hide()
	##item_trade_menu.hide();
	##recruitment_menu.hide()
	
	main_view.show();
	current_view = main_view;
