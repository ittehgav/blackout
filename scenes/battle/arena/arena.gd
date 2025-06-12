extends Node2D

class_name Arena;

## keep this information and only emit won/lost signal when you exit the arena
## any interactions that depend on whether or not the player won will 
## be bound to the signals
var won_battle:bool;
var battle_ongoing:bool=true;


@export var overlay:Control;
@export var kill_feed:Control;

@export var team_1:Team;
@export var team_2:Team;
@export var projectiles:Node2D;

@export var tide_bar:TextureProgressBar;

var battle_exp_value:float=0;
var battle_loot:Inventory;


func start_battle(enemy_leader:Leader)->void:
	Entities.main.current_state = "battle"
	Entities.arena = self;

	load_teams(enemy_leader);
	if Entities.world_map:
		## for testing battle straight out of the main menu
		Entities.in_map_player.camera.enabled = false
		Entities.world_map.hide()

	Entities.main.add_child(self)
	get_tree().paused = false
	overlay.tide_bar.set_tide_bar();

	generate_battle_reward(enemy_leader);

func return_to_world_map()->void:
	var camera:Camera2D = Entities.in_map_player.camera;
	camera.enabled = true
	camera.reparent(Entities.in_map_player)
	camera.global_position = Entities.in_map_player.global_position;
	Entities.world_map.unpause_map();
	Entities.world_map.show()
	#Entities.main_bgm.play_bgm("world_map");
	Entities.main.current_state = "world_map"
	

	queue_free()
	Entities.main.add_child(Entities.world_map)
	Entities.world_map.returned_from_battle.emit(won_battle);

func generate_battle_reward(enemy_leader:Leader)->void:
	for fighter:ActiveFighter in team_2.units:
		battle_exp_value += fighter.unit.level;
	
	battle_loot = enemy_leader.inventory
		


func load_teams(enemy_leader:Leader)->void:
	## happens before ready?
	
	team_1.initial_party_size = len(Entities.player.roster.units) + 1;
	## ugly way to assign player fighter
	assign_team(team_1.get_child(0), 1, Entities.player);
	Entities.player.load_party(team_1, 1);
	team_1.leader = Entities.player
	

	team_2.initial_party_size = len(enemy_leader.roster.units) + 1
	enemy_leader.load_party(team_2, 2);





func player_died(_killer:ActiveFighter)->void:
	battle_over(2);

func battle_over(winner:int)->void:
	won_battle = winner == 1;
	battle_ongoing = false
	overlay.post_fight.show_post_fight(winner)
	
func assign_team(unit:ActiveFighter, team_n:int, leader:Leader)->void:
	var enemy_team_n:int = 2 if team_n == 1 else 1;
	var ally_team:Team = self["team_" + str(team_n)];
	ally_team.assign_unit(unit);
	
	unit.set_collision_layer_value(team_n, true);
	unit.set_collision_mask_value(enemy_team_n, true)
	
	
	if not unit is InFightPlayer:
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

	unit.death.connect(overlay.tide_bar.on_unit_death.bind(unit))
	unit.death.connect(kill_feed.unit_died.bind(unit))

func _process(_delta:float)->void:
	if Input.is_action_just_pressed("world_map_zoom_in"):
		if scale == Vector2.ONE or scale == Vector2(.5, .5):
			var target_scale:Vector2 = scale * 2
			
			var tween:Tween = create_tween();
			tween.tween_property(self, "scale", target_scale, 1)
	elif Input.is_action_just_pressed("world_map_zoom_out"):
		if scale == Vector2.ONE or scale == Vector2(2, 2):
			var target_scale:Vector2 = scale / 2
			
			var tween:Tween = create_tween();
			tween.tween_property(self, "scale", target_scale, 1)
