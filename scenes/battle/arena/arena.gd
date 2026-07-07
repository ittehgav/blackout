@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_trophy.png")
extends Node2D
class_name Arena;

signal battle_started
signal battle_ended(won:bool);


## used for nodes outside of the arena contex to interact with wether the player won or lost

@export var team_1:Team;
@export var team_2:Team;

@export var current_layout:Node2D;

## only checked during post_fight
var won_battle:bool;
@export var post_fight_view:PostFight;

func _enter_tree() -> void:
	Entities.arena = self;

func _ready()->void:
	if team_1.roster:
		team_1.load_roster();
	if team_2.roster:
		team_2.load_roster();
	await get_tree().process_frame
	## to make sure every fighter is in the tree before setting up vfxes
	for f:ActiveFighter in team_1.fighters + team_2.fighters:
		if f is NpcFighter and f.base and "fight_start_setup" in f.base:
			f.base.fight_start_setup();

	for vfx:Node in get_tree().get_nodes_in_group("combat_vfx"):
		vfx.set_sprite_root();

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
