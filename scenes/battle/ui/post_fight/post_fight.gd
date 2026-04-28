extends UIRoot
class_name PostFight;

signal post_fight_finished;

@export var bgm:AudioStreamPlayer;
@export var victory_song:AudioStream;
@export var defeat_song:AudioStream;


@export var victory_sequence:Control;
@export var defeat_sequence:Control;
@export var player_exp_bar:ExperienceBar

@export_subgroup("test")

@export var player_sample:Player;
@export var enemy_roster_sample:NpcRoster
@export var test_won:bool;

@onready var player:Player = get_tree().get_first_node_in_group("player")


var enemy_roster:NpcRoster;

func _ready()->void:
	super()
	if player_sample:
		player = player_sample;
		enemy_roster = enemy_roster_sample
		player_exp_bar.build(player)
		start_post_fight(test_won)
	else:
		enemy_roster = Entities.arena.team_2.roster;
		player_exp_bar.build(player)
	

func start_post_fight(won:bool)->void:
	show();
	
	if won:
		bgm.stream = victory_song;
		victory_sequence.start_sequence()
	else:
		bgm.stream = defeat_song;
		defeat_sequence.start_sequence()
	
	bgm.play();


func _on_finish_post_fight_pressed() -> void:
	post_fight_finished.emit()
	bgm.stop()
