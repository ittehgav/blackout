@icon("res://assets/visual/editor_ui/IconGodotNode/control/icon_flag.png")
extends UIRoot
class_name LocationMenu;

signal opened;
signal closed

signal menu_opened;
signal menu_closed;

@export var content_vbox:VBoxContainer;
@export var name_label:Label;
@export var location_vboxes:Array[VBoxContainer]


@export var trade_menu:TradeMenu;
@export var recruitment_menu:RecruitmentMenu;
@export var evolve_menu:EvolutionMenu;
@export var refinement_menu:RefinementMenu;
@export var dungeon_menu:DungeonMenu
var current_location:Location;


@export_subgroup("test")
@export var mock_location:Location;

func _ready()->void:
	super()
	if mock_location:
		mock_location.refresh_settlements()
		display_location(mock_location);

		

func display_location(target:Location=Entities.player_party.current_location)->void:
	## NEEDS TO CLEAR PREVIOUS DATA
	State.set_substate(State.Substate.location_menu);
	current_location = target;
	content_vbox.show();
	dungeon_menu.hide();
	if target.settlements[0] is Dungeon:
		menu_opened.emit()
		dungeon_menu.load_dungeon(target.settlements[0]);
		content_vbox.hide()
		show()
		return

	name_label.text = target.name;
	
	var i:int = 0;
	for v:VBoxContainer in location_vboxes:
		v.hide()
	
	for settlement:Settlement in target.settlements:
		
		var vbox:VBoxContainer = location_vboxes[i];
		vbox.show()
		var portrait:TextureRect = vbox.get_node("portrait")
		
		
		var bname_label:Label = vbox.get_node("portrait/building_name");
		bname_label.text = settlement.name;
		
		portrait.self_modulate = settlement.theme_color
		
		i += 1;
		portrait.show();
		portrait.custom_minimum_size.x = 256 * settlement.size;
		portrait.texture = settlement.portrait
		
		
		var options:LocationOptions = vbox.get_node("LocationOptions");
		options.load_building(settlement);
	slide_in();
	opened.emit()

const hidden_separation = 2000;
func slide_in()->void:
	show()
	content_vbox.add_theme_constant_override("separation", hidden_separation);
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(content_vbox, "theme_override_constants/separation", 4, .5)

func slide_out()->Tween:
	## DOES NOT HIDE
	## slides out when exiting and when
	## transitioning to other menus
	var tween:Tween = create_tween();
	tween.tween_property(content_vbox, "theme_override_constants/separation", hidden_separation, .5)
	return tween



func on_menu_closed() -> void:
	## emit this both ways to reverse UI
	## buy maybe this should be on state machine?
	menu_closed.emit()

	if current_location.settlements[0] is Dungeon:
		close_location_menu();
	else:
		slide_in()

func _on_l_1_mouse_entered() -> void:
	highlight_location(0)

func _on_l_2_mouse_entered() -> void:
	highlight_location(1)

func _on_l_3_mouse_entered() -> void:
	highlight_location(2)

@onready var highlight_tween:Tween = create_tween();
func highlight_location(index:int)->void:
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween = create_tween();
	for i:int in range(3):
		var vbox:VBoxContainer = location_vboxes[i];
		if i != index:
			highlight_tween.tween_property(vbox, "modulate:v", .5, .5)
		else:
			vbox.modulate.v = 1;


func _on_option_chosen(building:Building, option: Building.Option, extra_arg:Variant = null) -> void:
	menu_opened.emit()
	match option:
		Building.Option.trade:
			## right now only using it here, 
			## will add more overrides as i 
			## create featres that demand them
			if extra_arg:
				trade_menu.start_trade(building.inventory, building.name, extra_arg);
			else:
				trade_menu.start_trade(building.inventory, building.name);
			slide_out()
		Building.Option.recruit:
			recruitment_menu.start_recruitment(building.roster);
			slide_out()
		Building.Option.evolve:
			evolve_menu.start_evolution_menu()
			slide_out()
		Building.Option.refine:
			refinement_menu.start_refinement_menu()
			slide_out()


func _on_exit_pressed() -> void:
	close_location_menu()	

func close_location_menu()->void:
	slide_out()
	await get_tree().create_timer(.5).timeout;
	State.revert_substate();
	hide()
	closed.emit()


func _on_world_map_returned_from_battle(won: bool) -> void:
	dungeon_menu.show_post_fight(won)
