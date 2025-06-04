extends Control

@export var floating_memo:Panel;

@export var sfx:AudioStreamPlayer;

@onready var panel_base_z:int = party_panel.z_index;
const panel_z_shift = 2;

@export var clock:Label;
@export var date:Label;

@export var party_panel:PanelContainer;
@export var resources_panel:PanelContainer;
@export var clock_panel:PanelContainer;
@export var navigation:PanelContainer;

var fade_tweens:Dictionary[PanelContainer, Tween]={}

const resoureces_panel_mouseover_shift = Vector2(5, 5);
const party_status_panel_mouseover_shift = Vector2(5, 5);

@onready var all_panels:Array[PanelContainer] = [party_panel, resources_panel, clock_panel, navigation]

func _ready()->void:
	for p in all_panels:
		fade_tweens[p] = null;


func update_clock() -> void:
	var hour:int = Entities.world_map.current_hour;
	var minute:int = Entities.world_map.current_minute;
	
	var time_string:String ="";
	if hour < 10:
		time_string += "0" 
	time_string += str(hour);
	time_string += ":";
	if minute<10:
		time_string += "0";
	time_string += str(minute);
	clock.text = time_string
	
	var day:int = Entities.world_map.current_day;
	var month:int = Entities.world_map.current_month;
	
	var date_string:String = "";
	if day < 10:
		date_string += "0";
	date_string += str(day);
	date_string += "/";
	
	if month < 10:
		date_string += "0";
	date_string += str(month);
	
	date.text = date_string


func turn_semi_visible(panel:PanelContainer)->void:
	panel.show()
	panel.modulate.a = .1;
	panel.z_index -= panel_z_shift
	panel.mouse_entered.connect(fade_panel_in.bind(panel));
	panel.mouse_exited.connect(fade_panel_out.bind(panel))

func turn_fully_visible(panel:PanelContainer)->void:
	panel.show()
	panel.modulate.a = 1;
	
	panel.z_index = panel_base_z
	
	for c:Dictionary in panel.mouse_entered.get_connections():
		if c.callable == fade_panel_in.bind(panel):
			panel.mouse_entered.disconnect(fade_panel_in);
	
	for c:Dictionary in panel.mouse_exited.get_connections():
		if c.callable == fade_panel_out.bind(panel):
			panel.mouse_exited.disconnect(fade_panel_out)
	


func switch_to_semi_visible(_s:Node=null)->void:
	for panel:PanelContainer in all_panels:
		turn_semi_visible(panel)

func switch_to_fully_visible()->void:
	for panel:PanelContainer in all_panels:
		turn_fully_visible(panel);

func fade_panel_in(panel:PanelContainer)->void:
	panel.z_index += panel_z_shift
	if fade_tweens[panel] and fade_tweens[panel].is_running():
		fade_tweens[panel].kill()
	fade_tweens[panel] = create_tween();
	fade_tweens[panel].tween_property(panel, "modulate:a", 1, .1);

	
func fade_panel_out(panel:PanelContainer)->void:
	panel.z_index = panel_base_z - panel_z_shift
	if fade_tweens[panel] and fade_tweens[panel].is_running():
		fade_tweens[panel].kill()
	fade_tweens[panel] = create_tween();
	fade_tweens[panel].tween_property(panel, "modulate:a", .1, .5);


func _on_resources_panel_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		Entities.player_sheet.show_player_sheet();


func _on_party_status_panel_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == 1 and e.pressed:
		Entities.player_sheet.show_player_sheet(1);

func _on_resources_panel_mouse_entered() -> void:
	resources_panel.position += resoureces_panel_mouseover_shift;
func _on_resources_panel_mouse_exited() -> void:
	resources_panel.position -= resoureces_panel_mouseover_shift;

func _on_party_status_panel_mouse_entered() -> void:
	party_panel.position += party_status_panel_mouseover_shift
func _on_party_status_panel_mouse_exited() -> void:
	party_panel.position -= party_status_panel_mouseover_shift

func settlement_main_view(_settlement: Settlement=null) -> void:
	turn_semi_visible(party_panel)
	turn_semi_visible(resources_panel)
	turn_fully_visible(clock_panel)
	navigation.hide();
func _on_settlement_ui_settlement_left() -> void:
	switch_to_fully_visible()

func _on_settlement_ui_trade_started() -> void:
	resources_panel.hide();
	party_panel.hide()
	clock_panel.hide()
	navigation.hide()
func _on_settlement_ui_trade_finished() -> void:
	settlement_main_view()

func _on_settlement_ui_listen_around_started() -> void:
	party_panel.hide();
	resources_panel.hide();
	clock_panel.hide()
func _on_settlement_ui_listen_around_ended() -> void:
	settlement_main_view();

func _on_settlement_ui_recruitment_started() -> void:
	clock_panel.hide();
	turn_fully_visible(resources_panel);
	turn_fully_visible(party_panel);
	navigation.hide()

func _on_settlement_ui_recruitment_ended() -> void:
	settlement_main_view();


func notify_new_memo(_memo: Memo) -> void:
	if not Entities.world_map.pause_stack:
		sfx.play_sound_by_key("new_memo");
		
		var memo:Panel = floating_memo.duplicate();
		add_child(memo);
		memo.show();
		var tween:Tween = create_tween();
		tween.tween_property(memo, "position:y", memo.position.y + 50, 2);
		tween.parallel().tween_property(memo, "modulate:a", 0, 3);
		tween.tween_callback(memo.free);

	else:
		Entities.world_map.map_unpaused.connect(notify_new_memo.bind(_memo),  CONNECT_ONE_SHOT);


func _on_pre_battle_pre_battle_started() -> void:
	for p in all_panels:
		p.hide()


func _on_trade_menu_trade_started() -> void:
	for p in all_panels:
		p.hide()


func _on_world_map_returned_from_battle(_won: bool) -> void:
	switch_to_fully_visible()


func _on_daily_upkeep_daily_upkeep_prompted() -> void:
	for p in all_panels:
		p.hide();


func _on_daily_upkeep_daily_upkeep_finished() -> void:
	switch_to_fully_visible();
