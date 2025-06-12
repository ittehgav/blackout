extends UIRoot;

class_name PlayerSheet;

@export var bg:ColorRect;
@export var sfx:AudioStreamPlayer;
 
@export var party_view:Control;
@export var player_view:Panel;
@export var memos_view:Control;
@export var player_inventory:InventoryDisplay;

@export_group("elements")
@export var left_tab_container:TabContainer;
@export var container:HBoxContainer;
@export var gear:Control;
@export var morale_label:Label;

@export var recruit_full_view:Control;

@export_subgroup("sounds")
@export var open_sound:AudioStream;
@export var close_sound:AudioStream;
@export var rummage:AudioStream;
@export var consumable_used:AudioStream;
@export var equip:AudioStream;

@export_category("Elements")
@export_subgroup("Combat Stat Labels")
@export var max_hp_label:Label;
@export var attack_label:Label;
@export var defense_label:Label;
@export var agility_label:Label;
@export var technique_label:Label;

const resources_names = [
	"food", "fuel", "money", "scrap", "juice", "scrap", "chips"
]

@export_subgroup("Levels")
@export var leadership_level_label:Label;
@export var leadership_level_progress:ProgressBar;

@export var combat_level_label:Label;
@export var combat_level_progress:ProgressBar;


func _ready()->void:
	super();
	Entities.player_sheet = self;



func _input(e:InputEvent)->void:
	if e.is_action_pressed("show_player_sheet") and not visible:
		show_player_sheet()
	elif visible and not recruit_full_view.visible and (e.is_action_pressed("ui_cancel")\
	 or e.is_action_pressed("show_player_sheet")):
		if not player_inventory.warnings_popup.visible:
			hide_player_sheet();
				


func show_player_sheet(left_tab_view:int=0)->void:
	left_tab_container.get_child(left_tab_view).show()
	ui_sfx.play_stream_obj(open_sound)
	show()
	refresh_data();
	Entities.in_map_player.stop_movement(false)
	get_tree().paused = true;
	Entities.world_map.pause_map()
	bg.self_modulate.a = 0;
	
	const tween_duration = .4;
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(bg, "self_modulate:a", 1, tween_duration);
	tween.parallel().tween_property(container, "theme_override_constants/separation", 20, tween_duration)


func hide_player_sheet(_meta:Variant="")->void:
	## _meta to this gets called when meta clicked from memo labels in the memos tab
	if player_inventory.pending_warnings():
		player_inventory.warn_player();
		var clear:bool = await player_inventory.warnings_attended;
		if clear:
			hide_player_sheet();
	else:
		player_inventory.update_inventory();
		ui_sfx.play_stream_obj(close_sound)
		const tween_duration = .25;
		var tween:Tween = create_tween();
		tween.tween_property(container, "theme_override_constants/separation", 1700, tween_duration);
		tween.parallel().tween_property(bg, "self_modulate:a", 0, tween_duration)
		await tween.finished
		Entities.world_map.unpause_map()
		hide()


func refresh_data(_r:String="", _change:float=0)->void:
	## will show upkeep costs when upkeep is implemented
	if visible:
		## runs when you open inventory so
		## only needs to refresh off of signals when change happens in-context
		morale_label.text = "Morale: " + str(snapped(Entities.player.morale, .01));
		
		gear.refresh_samples()


		player_inventory.refresh_data(true);
		party_view.refresh_data();
		player_view.refresh_data();
		memos_view.refresh_data();

func _on_player_equipment_changed(changed:Equipment) -> void:
	gear.refresh_samples(changed)


func _on_player_new_memo(_memo: Memo) -> void:
	memos_view.refresh_data();


func _on_inventory_display_warnings_shown() -> void:
	left_tab_container.set_tab_disabled(1, true)
	left_tab_container.set_tab_disabled(2, true)


func _on_inventory_display_warnings_attended(_clear: bool) -> void:
	left_tab_container.set_tab_disabled(1, false)
	left_tab_container.set_tab_disabled(2, false)
	
