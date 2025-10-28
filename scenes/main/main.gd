extends Node

class_name Main;

## main substate = no substate
## some kinda inherit others and some if not most change calls won't do much
## can probably transport a lot of functionalities to just dealing with state/substate changes

## SCENARIOS:
## main, world_map, in_settlement, battle
signal scenario_changed(new:String, old:String);
var scenario:String="main";

## SUBSTATES
## main, dialogue, player_sheet, trade, pre_battle, post_battle,
## battle_finishing
## substates can be used as quick ways to change bgm/UI layouts?
## is it ok to have a ton of substates that only get set once in the lifetime of their scenario?
signal substate_changed(new:String, old:String)
var substate:String="main";


@export var main_menu_ui_scene:PackedScene;

@export var main_bgm:AudioStreamPlayer

func _ready()->void:
	Entities.main = self;
	
func return_to_main_menu()->void:
	await Tweens.ui_fade_in(Entities.loading_screen).finished;
	Entities.world_map.free();
	get_tree().paused = false
	
	var main_menu_ui:CanvasLayer = main_menu_ui_scene.instantiate();
	main_menu_ui.tree_entered.connect(Entities.loading_screen.fade_out)
	add_child(main_menu_ui)
	move_child(main_menu_ui, 1)

func set_scenario(target:String)->void:
	## all scenario transitions are gonna be single calls to this function that'll fectch/manipulate 
	## data from the global scope
	var previous:String = scenario
	scenario = target


	match target:
		## control all status changes and keep them broken down into each combination of transition
		"world_map":
			match previous:
				"main":
					await Entities.loading_screen.show_splash().finished
					## eventually this becomes new game as opposed to just starting the world map
					## can break them down based on substate to keep common calls together
					Entities.world_map = Index.scenes.world_map.instantiate();
					Entities.player = Entities.world_map.player_node;

					Entities.world_map.ready.connect(Entities.loading_screen.clear_splash, CONNECT_ONE_SHOT)
					add_child(Entities.world_map);
					## day_passed only right as new game startgs
					Entities.world_map.advance_day()
					Entities.player.reparent(self)
				"in_settlement":
					await Entities.loading_screen.show_splash().finished
					add_child(Entities.world_map);
					
					Entities.player_party.visit_settlement()
					
					var tween:Tween = Tweens.ui_fade_out(Entities.current_area)
					tween.finished.connect(Entities.current_area.queue_free)
					tween.finished.connect(Entities.loading_screen.clear_splash)
				"battle":
					var tween:Tween = Tweens.ui_fade_out(Entities.arena.post_fight_view);
					tween.finished.connect(Entities.arena.queue_free);
					tween.finished.connect(Entities.loading_screen.clear_splash)
					var won:bool = Entities.arena.won_battle
					await Entities.loading_screen.show_splash().finished;
					add_child(Entities.world_map);
					Entities.world_map.returned_from_battle.emit(won);
					Entities.player_party.visit_settlement()
					

		"in_settlement":
			match previous:
				"world_map":
					await Entities.loading_screen.show_splash().finished
					remove_child(Entities.world_map);

					var in_settlement:Node2D = Index.scenes.in_settlement.instantiate();
					in_settlement.ready.connect(Entities.loading_screen.clear_splash, CONNECT_ONE_SHOT)
					in_settlement.load_settlement(Entities.player_party.current_settlement)
					
					add_child(in_settlement)
	
		"battle":
			match previous:
				"world_map":
					## where this will fork into other places to get enemy parties from
					## when those are added
					var dungeon:Dungeon = Entities.current_dungeon

					var arena:Arena = Index.scenes.arena.instantiate();
					Entities.arena = arena;
					arena.load_layout(dungeon.tile_layout_scene);

					arena.team_1.roster = Entities.player.roster;
					arena.team_2.roster = dungeon.get_current_wave()
					
					add_child(arena)
					remove_child(Entities.world_map);
	scenario_changed.emit(scenario, previous)
func revert_substate()->void:
	## right now just leave it like this but it's gonna probably 
	## need to change dynamically when UX gets deeper
	set_substate("main")

var previous_pause_state:bool;
func set_substate(target:String)->void:
	## will be used to control pause state of tree
	## and disposition of some UI elements?
	
	var previous:String = substate
	substate = target
	substate_changed.emit(substate, previous)
	
	match target:
		"main":
			match previous:
				"player_sheet":
					get_tree().paused = previous_pause_state
				"dungeon_prompt":
					## TODO make visit_settlement into something more
					## comprehensive/explicit to prompt the player?
					Entities.player_party.visit_settlement()

		"player_sheet":
			previous_pause_state = get_tree().paused;
			get_tree().paused = true

		
