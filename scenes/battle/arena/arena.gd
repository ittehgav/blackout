extends Node2D

class_name Arena;

signal battle_started
signal battle_ended(won:bool);

## used for nodes outside of the arena contex to interact with wether the player won or lost

@export var team_1:Team;
@export var team_2:Team;

@export var current_layout:Node2D;

## only checked during post_fight
var battle_over:bool=false
var won_battle:bool;
@export var post_fight_view:Control;


func _ready()->void:
	team_1.load_roster();
	team_2.load_roster()
	
	var projections:Array[Node] = get_tree().get_nodes_in_group("aoe_projections");  
	var player_team_n:int = Entities.player_fighter.ally_team.team_n;
	for p in projections:
		if p.owner.fighter.ally_team.team_n == player_team_n:
			p.hide();

func load_layout(target:PackedScene)->void:
	current_layout.queue_free();
	current_layout = target.instantiate()
	current_layout.z_index = -1;
	add_child(current_layout);
	move_child(current_layout, 0);

func start_post_battle(won:bool=false)->void:
	battle_ended.emit(won)
	battle_over = true
	Entities.main.set_substate("battle_finishing")
	won_battle = won;
	var tween:Tween = create_tween();
	tween.tween_property(Engine, "time_scale", .5, .3);
	tween.tween_callback(show_post_fight)

func show_post_fight()->void:
	Engine.time_scale = 1;
	get_tree().paused = true
	Entities.main.set_substate("post_battle");
	post_fight_view.show_post_fight();
