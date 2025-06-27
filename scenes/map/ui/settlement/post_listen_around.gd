extends Control

@export var memo_label_scene:PackedScene

@export var settlement_ui:UIRoot;
@export var main_view:Control;

@export var post_listen_around_list:VBoxContainer;

var fading:bool = false;

func listen_around() -> void:
	settlement_ui.listen_around_started.emit()
	settlement_ui.listening_around = true;

	var tween:Tween = await settlement_ui.sky_props.pass_time(3, true);
	await tween.finished

	for c in post_listen_around_list.get_children():
		if c.visible and c is RichTextLabel:
			c.queue_free();
	
	var all_anomalies:Array[Memo] = []
	for neighbor:Settlement in Entities.current_settlement.neighbors:
		all_anomalies.append(neighbor.ongoing_trade_anomaly);
		if neighbor.local_event:
			all_anomalies.append(neighbor.local_event)

	var found:Array[Memo];
	while len(found) < 3:
		var pick:Memo = all_anomalies.pick_random();
		if not (pick in found):
			found.append(pick)
			

	for memo:Memo in found:
		var label:MemoLabel = memo_label_scene.instantiate()
		label.show()
		label.text = memo.gossip;
		post_listen_around_list.add_child(label);
		label.adjust_size();
		memo.register_memo()

	
	main_view.hide();
	main_view.modulate.a = 1;
	modulate.a = 0;
	show();
	
	var return_tween:Tween = settlement_ui.sky_props.return_camera()
	return_tween.tween_property(self, "modulate:a", 1, 1)
	await return_tween.finished;
	settlement_ui.listening_around = false
	settlement_ui.listen_around_ended.emit()

func _ready()->void:
	set_process_input(false)

func _input(e: InputEvent) -> void:
	if (e is InputEventMouseButton or e is InputEventKey) and e.pressed and not fading:
		fade_out();

func fade_out()->void:
	main_view.modulate.a = 0;
	main_view.show();
	
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 0, .25);
	tween.parallel().tween_property(main_view, "modulate:a", 1, .25);
	tween.tween_callback(hide)
	fading = true;
	await tween.finished;
	fading = false


func _on_memo_label_meta_clicked(_key: Variant) -> void:
	settlement_ui.exit_settlement()
	

	
func _on_visibility_changed() -> void:
	set_process_input(visible);
