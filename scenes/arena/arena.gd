extends Node2D


@export var team_1_node:Node2D;
@export var team_2_node:Node2D;

var team_1:Array[Node];
var team_2:Array[Node];

func _ready() -> void:
	team_1 = team_1_node.get_children();
	team_2 = team_2_node.get_children();
	match_teams()

func match_teams():
	for unit in team_1:
		unit.ally_team = team_1;
		unit.enemy_team = team_2;
		unit.death.connect(check_battle_over)
	for unit in team_2:
		unit.ally_team = team_2;
		unit.enemy_team = team_1
		unit.death.connect(check_battle_over)


func check_battle_over(_killer:CharacterBody2D):
	if not len(team_1):
		battle_over(2);
	elif not len(team_2):
		battle_over(1);
		
func battle_over(winner:int):
	get_tree().paused = true;
	$hud/post_fight.show_post_fight(winner)
	
