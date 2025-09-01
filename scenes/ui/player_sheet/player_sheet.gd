extends UIRoot;

class_name PlayerSheet;

@export var bg:ColorRect;
@export var sfx:AudioStreamPlayer;
 
@export var party_view:Control;
@export var inventory_view:Control;
@export var player_view:Panel;
@export var player_inventory:InventoryDisplay;

@export_group("elements")
@export var left_tab_container:TabContainer;
@export var container:HBoxContainer;
@export var gear:Control;
@export var morale_label:Label;


@export_subgroup("sounds")
@export var open_sound:AudioStream;
@export var close_sound:AudioStream;
@export var rummage:AudioStream;
@export var consumable_used:AudioStream;
@export var equip:AudioStream;



func _ready()->void:
	super();
	Entities.player_sheet = self;


func show_player_sheet(left_tab_view:int=0)->void:
	left_tab_container.get_child(left_tab_view).show()
	ui_sfx.play_stream_obj(open_sound)
	show()
	refresh_data();
	get_tree().paused = true;
	bg.self_modulate.a = 0;
	
	const tween_duration = .4;
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(bg, "self_modulate:a", 1, tween_duration);
	tween.parallel().tween_property(container, "theme_override_constants/separation", 20, tween_duration)
	tween.tween_callback(opening_finished)
	## so the player can't mash tab and bug the UI

var open:bool=false
func opening_finished()->void:
	open = true
func closing_finished()->void:
	open = false

func _input(e:InputEvent)->void:
	## opening is handled differently in contexts
	if e.is_action_pressed("show_player_sheet") and open and not party_view.current_unit_sheet:
		hide_player_sheet();

func hide_player_sheet(_meta:Variant="")->void:
	## _meta to this gets called when meta clicked from memo labels in the memos tab
	if player_inventory.pending_warnings():
		inventory_view.show();
		player_inventory.warn_player();
		var clear:bool = await player_inventory.warnings_attended;
		if clear:
			hide_player_sheet();
	else:
		ui_sfx.play_stream_obj(close_sound)
		const tween_duration = .25;
		var tween:Tween = create_tween();
		tween.tween_property(container, "theme_override_constants/separation", 1700, tween_duration);
		tween.parallel().tween_property(bg, "self_modulate:a", 0, tween_duration)
		await tween.finished
		open = false
		if Entities.main.state == "location":
			get_tree().paused = false;
		hide()


func refresh_data(_r:String="", _change:float=0)->void:
	## will show upkeep costs when upkeep is implemented
	if visible:
		## runs when you open inventory so
		## only needs to refresh off of signals when change happens in-context
		morale_label.text = "Morale: " + str(snapped(Entities.player.morale, .01));
		
		gear.refresh_samples()


		player_inventory.refresh_data();
		party_view.refresh_data();
		player_view.refresh_data();

func _on_player_equipment_changed(changed:Equipment) -> void:
	gear.refresh_samples(changed)




func _on_inventory_display_warnings_shown() -> void:
	left_tab_container.set_tab_disabled(1, true)
	left_tab_container.set_tab_disabled(2, true)


func _on_inventory_display_warnings_attended(_clear: bool) -> void:
	left_tab_container.set_tab_disabled(1, false)
	left_tab_container.set_tab_disabled(2, false)
	
