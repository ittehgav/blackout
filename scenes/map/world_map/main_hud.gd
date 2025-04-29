extends Control


@export var clock:Label;
@export var date:Label;

@export var fade_tweens:Dictionary[PanelContainer, Variant]={}

const resoureces_panel_mouseover_shift = Vector2(5, -5);
const party_status_panel_mouseover_shift = Vector2(5, 5);



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



func switch_to_semi_visible(_s:Node=null)->void:
	for c:Node in get_children():
		if c is PanelContainer:
			c.modulate.a = .1
			c.mouse_entered.connect(fade_panel_in.bind(c))
			c.mouse_exited.connect(fade_panel_out.bind(c))

func fade_panel_in(panel:PanelContainer)->void:
	if fade_tweens[panel] and fade_tweens[panel].is_running():
		fade_tweens[panel].kill()
	fade_tweens[panel] = create_tween();
	fade_tweens[panel].tween_property(panel, "modulate:a", 1, .1);
	
	
func fade_panel_out(panel:PanelContainer)->void:
	if fade_tweens[panel] and fade_tweens[panel].is_running():
		fade_tweens[panel].kill()
	fade_tweens[panel] = create_tween();
	fade_tweens[panel].tween_property(panel, "modulate:a", .1, .5);

func switch_to_fully_visible()->void:
	for c:Node in get_children():
		if c is PanelContainer:
			c.modulate.a = 1
			c.mouse_entered.disconnect(fade_panel_in.bind(c))
			c.mouse_exited.disconnect(fade_panel_out.bind(c))


func _on_party_status_panel_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		Entities.player_sheet.show_player_sheet(1);



func _on_resources_panel_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		Entities.player_sheet.show_player_sheet();


func _on_resources_panel_mouse_entered() -> void:
	$resources_panel.position += resoureces_panel_mouseover_shift;


func _on_resources_panel_mouse_exited() -> void:
	$resources_panel.position -= resoureces_panel_mouseover_shift;


func _on_party_status_panel_mouse_entered() -> void:
	$party_status_panel.position += party_status_panel_mouseover_shift


func _on_party_status_panel_mouse_exited() -> void:
	$party_status_panel.position -= party_status_panel_mouseover_shift
