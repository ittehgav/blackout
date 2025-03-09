extends Node2D

class_name Arena;

@export var npc_fighter_scene:PackedScene;
@export var overlay:Control;

@export var team_1:Team;
@export var team_2:Team;


## TODO: TIDE OF BATTLE
## battles end not necessarily by one party being wiped out but the tide meter
## going all the way to one side, usually when a party is getting really 
## tactic mechanics will be intertwined with this probably?

## SIMPLE VERSION THAT GOES INTO THE BETA:
## tide of battle is one team's combined HP vs the other's(?)
## battle ends when one partys has about 5x more combined HP
## or when either party has no more means to deal damage

## when the tide is too one-sided, parties may desert or the leader may take the decision to flee
## the player's party will also flee if the tide of battle is too bad


func start_battle(enemy_leader:Leader):
	Entities.arena = self;
	Entities.in_map_player.camera.enabled = false;
	load_teams(enemy_leader);
	overlay.tide_bar.set_tide_bar();
	
	Entities.world_map.hide();
	Entities.world_map.ui.hide();
	Entities.world_map.ui.hide();
	Entities.main.add_child(self)


func load_teams(enemy_leader:Leader):
	## happens before ready?
	Entities.player.load_party(team_1, npc_fighter_scene);
	team_1.refresh_units();
	## will leaders be part of the roster?
	
	enemy_leader.load_party(team_2, npc_fighter_scene, 500);
	
	var leader_unit:NpcFighter = npc_fighter_scene.instantiate();
	leader_unit.load_fighter(enemy_leader.leader_unit)
	team_2.add_child(leader_unit)
	team_2.refresh_units();
	
	leader_unit.position = Vector2(450, 50)

	match_teams()

func match_teams()->void:
	for unit:ActiveFighter in team_1.units:
		assign_team(unit, 1);

	for unit:ActiveFighter in team_2.units:
		assign_team(unit, 2)

func player_died():
	battle_over(2);

		
func battle_over(winner:int)->void:
	get_tree().paused = true;
	overlay.post_fight.show_post_fight(winner)
	
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
		
	if not unit is InFightPlayer:
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
	
	unit.death.connect(unit.ally_team.on_unit_death.bind(unit))
	unit.death.connect(overlay.tide_bar.refresh_tide_value.bind(unit))
