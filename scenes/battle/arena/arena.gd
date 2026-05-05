@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_trophy.png")
extends Node2D
class_name Arena;

signal battle_started
signal battle_ended(won:bool);

@export var grid:NavigationGrid

## used for nodes outside of the arena contex to interact with wether the player won or lost

@export var team_1:Team;
@export var team_2:Team;

@export var current_layout:Node2D;

## only checked during post_fight
var won_battle:bool;
@export var post_fight_view:PostFight;


func _ready()->void:
	team_1.load_roster();
	team_2.load_roster();
	Entities.arena = self

func load_layout(target:PackedScene)->void:
	current_layout.queue_free();
	current_layout = target.instantiate()
	current_layout.z_index = -1;
	add_child(current_layout);
	move_child(current_layout, 0);


func finish_battle(won:bool)->void:
	battle_ended.emit(won);
	won_battle = won;
	
	var tween:Tween = create_tween();
	tween.tween_property(Engine, "time_scale", .5, .3);
	tween.tween_callback(show_post_fight.bind(won))


func show_post_fight(won:bool)->void:
	State.set_substate(State.Substate.post_battle);
	Engine.time_scale = 1;
	post_fight_view.start_post_fight(won);


func return_to_world_map()->void:
	State.set_scenario(State.Scenario.world_map);


func _on_post_fight_finished() -> void:
	return_to_world_map()
