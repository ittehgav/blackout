extends UIRoot;

class_name PlayerSheet;

signal closed;
signal space_request_cleared;
signal item_discarded;

@export var bg:ColorRect;

 
@export var party_view:PartyView;
@export var inventory_view:InventoryView;
@export var player_view:PlayerView;
@export var player_inventory:InventoryDisplay;

@export_group("elements")
@export var left_tab_container:TabContainer;
@export var container:HBoxContainer;
@export var gear:Control;
@export var morale_label:Label;
@export var disable_display_rect:ColorRect;

@export var start_battle_prompt:MarginContainer
@export var item_space_request:PanelContainer


@export_subgroup("sounds")
@export var open_sound:AudioStream;
@export var close_sound:AudioStream;

@onready var player:Player = Entities.player



func _on_tree_entered() -> void:
	## do we really need to do it like this?
	Entities.player_sheet = self;

		

func _ready()->void:
	super();
	player.equipment_changed.connect(_on_player_equipment_changed);
	

var open:bool=false
func show_player_sheet(left_tab_view:int=0)->void:
	start_battle_prompt.hide();
	
	left_tab_container.get_child(left_tab_view).show()
	ui_sfx.play_stream_obj(open_sound)
	show()
	
	var overlapping_inventory_display:InventoryDisplay = player.inventory.last_display;

	player_inventory.open(false) 
	## not refreshing player inv right away bc it can be opened
	## on top of other inv displays and cause conflicts
	if overlapping_inventory_display and overlapping_inventory_display != player_inventory:
		player.inventory.last_display = overlapping_inventory_display;
		disable_display_rect.show();
	else:
		disable_display_rect.hide()
		
	refresh_data();
	bg.self_modulate.a = 0;
	
	const tween_duration = .4;
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(bg, "self_modulate:a", 1, tween_duration);
	tween.parallel().tween_property(container, "theme_override_constants/separation", 20, tween_duration)
	
	if State.current_substate != State.Substate.pre_battle:
		State.set_substate(State.Substate.player_sheet)
	await tween.finished;
	open = true;
	## so the player can't mash tab and bug the UI


func pre_battle_sheet()->void:
	show_player_sheet();
	start_battle_prompt.show();
	player_view.player_sample.hide()
	## is this too loose?
	Entities.world_map.returned_from_battle.connect(player_view.player_sample.show)

func request_space_for_item(item:Item)->void:
	State.set_substate(State.Substate.inventory_space_request);
	item_space_request.request_space_for_item(item)
	show_player_sheet();


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
		closed.emit();

		State.revert_substate()
		hide()



func _input(e:InputEvent)->void:
	## opening is handled differently in contexts
	if e.is_action_pressed("show_player_sheet") and open and not party_view.current_unit_sheet\
	and State.current_substate == State.Substate.player_sheet:
		## substate will not be player sheet if it's a special open
		## IE pre-combat and item space request
		hide_player_sheet();


func refresh_data(_r:String="", _change:float=0)->void:
	if visible:
		## runs when you open inventory so
		## only needs to refresh off of signals when change happens in-context
		morale_label.text = str(snapped(Entities.player.morale, .01));
		
		gear.refresh_samples()


		player_inventory.refresh_data();
		party_view.refresh_data();
		player_view.refresh_data();

func _on_player_equipment_changed(changed:Equipment) -> void:
	player_view.show()
	gear.refresh_samples(changed)
	player_view.refresh_data(changed)

func _on_inventory_display_warnings_shown() -> void:
	left_tab_container.set_tab_disabled(0, true)
	left_tab_container.set_tab_disabled(1, true)


func _on_inventory_display_warnings_attended(_clear: bool) -> void:
	left_tab_container.set_tab_disabled(0, false)
	left_tab_container.set_tab_disabled(1, false)
	


func _on_start_battle_pressed() -> void:
	## making this a signal so to start battle from any context
	## i just make the global call then pass it back to the emmiter
	## for context-sensitive setups
	## encapsulating most of the complexitiy out of player sheet
	hide_player_sheet();
	State.set_scenario(State.Scenario.battle)


func _on_sort_inventory_pressed() -> void:
	Entities.player.inventory.sort_items_by_size();
	inventory_view.inventory_display.hard_reset()


func consumable_feedback(item:Consumable)->void:
	const FB = Consumable.UseFeedback;
	for f:FB in item.feedback:
		match f:
			FB.board_shake:
				player_inventory.board_shake(5);
			FB.show_player_view:
				player_view.show();
			FB.show_party_view:
				party_view.show();
			FB.play_sfx:
				ui_sfx.stream = item.use_sfx;
				ui_sfx.play();
