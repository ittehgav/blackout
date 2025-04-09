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
	var t1:Tween = create_tween();
	t1.tween_property(main_view, "modulate:a", 0, .25);
	t1.tween_callback(main_view.hide);
	
	trade_menu.open();
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
	for i in 3:
		Entities.world_map.hour_passed.emit();
		colors.append(Entities.world_map.get_hour_sky_color() * settlement_ui.sky_base_color);
	settlement_ui.color_bg();
	var sky_tween:Tween = create_tween();
	for color:Color in colors:
		sky_tween.tween_property(settlement_ui.sky_bg, "modulate", color, .5);

	await sky_tween.finished;
	if settlement_ui.crowd_rect.texture == settlement_ui.current_settlement.crowd_1:
		settlement_ui.crowd_rect.texture = settlement_ui.current_settlement.crowd_2
	else:
		settlement_ui.crowd_rect.texture = settlement_ui.current_settlement.crowd_1
		
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
		var label:Label = memo_label.duplicate(true);
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
