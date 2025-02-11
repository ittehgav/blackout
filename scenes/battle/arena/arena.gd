extends Node2D

class_name Arena;

@export var team_1_node:Node2D;
@export var team_2_node:Node2D;

var team_1:Array[ActiveFighter];
var team_2:Array[ActiveFighter];



func load_teams(enemy_leader:Leader):
	## happens before ready?
	team_1 = Entities.player.load_party(team_1_node);
	team_1.push_back($team_1/in_fight_player)
	## will leaders be part of the roster?
	team_2 = enemy_leader.load_party(team_2_node);
	$team_1/in_fight_player.load_fighter()
	match_teams()

func match_teams()->void:
	for unit:ActiveFighter in team_1:
		assign_team(unit, 1);

	for unit:ActiveFighter in team_2:
		assign_team(unit, 2)

func check_battle_over(_killer:ActiveFighter)->void:
	if not len(team_1):
		battle_over(2);
	elif not len(team_2):
		battle_over(1);
		
func battle_over(winner:int)->void:
	get_tree().paused = true;
	$hud/post_fight.show_post_fight(winner)
	
func assign_team(unit:ActiveFighter, team_n:int)->void:
	var enemy_team_n:int = 2 if team_n == 1 else 1;
	
	unit.set_collision_layer_value(team_n, true);

	unit.set_collision_mask_value(enemy_team_n, true)

	if team_n == 1:
		unit.ally_team = team_1;
		unit.enemy_team = team_2
	else:
		unit.ally_team = team_2;
		unit.enemy_team = team_1;
		
	if unit.name != "in_fight_player":
			ColorCoder.color_code_fighter(unit.base, team_n);

			var skill_range:Area2D = unit.get_node("skill_range")
			## break this down into enemy/ally targets:?
			match unit.base.target_type:
				"nearest_enemy":
					skill_range.set_collision_mask_value(enemy_team_n, true);
					
					var hit_scan:Node = unit.get_node_or_null("hit_scan");
					if hit_scan:
						hit_scan.set_collision_mask_value(enemy_team_n, true)
						
				"least_hp_ally":
					skill_range.set_collision_mask_value(team_n, true)
					
					var hit_scan:Node = unit.get_node_or_null("hit_scan");
					if hit_scan:
						hit_scan.set_collision_mask_value(enemy_team_n, true)
	else:
		var hit_scan:Node = unit.get_node_or_null("hit_scan");
		if hit_scan:
			hit_scan.set_collision_mask_value(enemy_team_n, true)
	
	unit.death.connect(check_battle_over)
