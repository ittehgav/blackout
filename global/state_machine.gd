extends Node

@export var test_arena_scene:PackedScene;

@export var tutorial_scene:PackedScene;
@export var demo_world_map_scene:PackedScene;

@export var bgm:AudioStreamPlayer;

var next_battle:Roster


enum Scenario{main, world_map, battle, \
				## regular, "true" scenarios
				tutorial, test_arena}; 
				## special scenarios that override the transition for 
				## regular scenarios
signal scenario_changed(new:Scenario, old:Scenario);
var current_scenario:Scenario;



var in_tutorial:bool=false;
var world_map_tutorial_completed:bool=false;
func set_scenario(target:Scenario)->void:
	## scenario transitions only available in F5 runs
	var previous:Scenario = current_scenario;
	current_scenario = target;
	var player:Player = get_tree().get_first_node_in_group("player")
	
	match target:
		Scenario.world_map:
			match previous:
				Scenario.main:
					## eventually this becomes new game as opposed to just starting the world map
					## can break them down based on substate to keep common calls together
					var world_map:WorldMap = Index.scenes.world_map.instantiate();
					Entities.world_map = world_map;

					
					Entities.main.add_child(world_map);
					## day_passed only right as new game startgs
					world_map.advance_day()

				Scenario.battle:
					
					await Splash.show_loading_screen().finished
					var tween:Tween = Tweens.ui_fade_out(Entities.arena.post_fight_view);
					if not in_tutorial:
						tween.finished.connect(Entities.arena.queue_free);
					else:
						tween.finished.connect(Entities.arena.get_parent().queue_free);
						
				
					var won:bool = Entities.arena.won_battle

					
					var world_map:WorldMap;
					if in_tutorial:
						player.reparent(Entities.main);
						var chosen_weapon:Weapon = Entities.arena.get_parent().chosen_weapon;
						if chosen_weapon.name == player.alternative_weapon.name:
							player.inventory.remove_item(player.equipped_weapon)
							player.equipped_weapon.queue_free();
							player.equipped_weapon = player.alternative_weapon;
						else:
							player.inventory.remove_item(player.alternative_weapon);
							player.alternative_weapon.queue_free();
						player.alternative_weapon = null
						
						
						world_map = demo_world_map_scene.instantiate();
						Entities.world_map = world_map;
						world_map.player_party.leader = player;
						## setting this after placing world map so it keeps the dungeon thingy from 
						## trying to play the clear animation
						in_tutorial = false;
					else:
						## world map only doesn't load first when you started at tutorial
						## so never right now but we keep this arond
						world_map = Entities.world_map;
						
					Splash.set_fade_callback(world_map.tree_entered);
					Entities.main.add_child(world_map);
					
					world_map.returned_from_battle.emit(won);

		Scenario.battle:
			match previous:
				Scenario.world_map:
					## where this will fork into other places to get enemy parties from
					## when those are added
					await Splash.show_loading_screen().finished;
					Entities.main.remove_child(Entities.world_map);
					var dungeon:Dungeon = Entities.current_dungeon

					var arena:Arena = Index.scenes.arena.instantiate();
					Entities.arena = arena;
					Splash.set_fade_callback(arena.tree_entered)
					arena.load_layout(dungeon.tile_layout_scene);

					arena.team_1.roster = player.roster;
					arena.team_2.roster = dungeon.get_current_wave()
					
					Entities.main.add_child(arena)
		Scenario.test_arena:
			## set calls for special instances
			## IE tests and tutorial
			## will override the initial scenario change calls
			## and change it to the true scenario
			current_scenario = Scenario.battle
			var arena:Node2D = test_arena_scene.instantiate().get_node("Arena");
			
			Entities.arena = arena;
			add_child(arena.get_parent())
		
		Scenario.tutorial:

			await Splash.show_loading_screen().finished
			current_scenario = Scenario.battle;
			in_tutorial = true;
			var arena:Node2D = tutorial_scene.instantiate().get_node("Arena");
			Splash.set_fade_callback(arena.tree_entered);
			Entities.arena = arena;

			Entities.main.add_child(arena.get_parent());

	revert_substate();
	scenario_changed.emit(current_scenario, previous)

var pause_state_stored:bool=false;
var previous_pause_state:bool;
enum Substate{main, dialogue, player_sheet, location_menu,\
			  pre_battle, post_battle, battle_finishing,
			dungeon_prompt, inventory_space_request}
	## TODO make these more directly tied to the scenarios they can
	## happen in?
	## SUBSTATES
	## substates can be used as quick ways to change bgm/UI layouts?
	## is it ok to have a ton of substates that only get set once in the lifetime of their scenario?
signal substate_changed(new:Substate, old:Substate);
var current_substate:Substate;
func set_substate(target:Substate)->void:
	## SUBSTATE CONTROLS TREE PAUSE STATUS
	var previous:Substate = current_substate;
	current_substate = target;
	substate_changed.emit(current_substate, previous);
	
	## this is how we keep UI commands from bleeding over that miss 
	## their release commands?
	Engine.time_scale = 1;
	
	match target:
		Substate.pre_battle:
			Entities.player_sheet.pre_battle_sheet();
			
		Substate.post_battle:
			get_tree().paused = true
		Substate.location_menu:
			catch_pause_state()
			get_tree().paused = true;

		Substate.main:
			match previous:
				Substate.player_sheet:
					reverse_pause_state()

		
		Substate.player_sheet:
			catch_pause_state()
			get_tree().paused = true


func catch_pause_state()->void:
	## ONLY USE THIS WHEN THE PAUSE STATE IS NOT THE SAME EVERY TIME
	## OTHERWISE JUST PAUSE/UNPAUSE AT SUBSTATE CHANGE
	previous_pause_state = get_tree().paused;
	pause_state_stored = true;
	
func reverse_pause_state()->void:
	assert(pause_state_stored)
	get_tree().paused = previous_pause_state
	pause_state_stored = false

func revert_substate()->void:
	## maybe make this switch to previous substate
	## if it ever seems to matter?
	set_substate(Substate.main)
