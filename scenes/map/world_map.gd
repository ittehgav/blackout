extends Node2D

class_name WorldMap

signal hour_passed;
signal day_passed;

@export var ui:Control;

@export var player:InMapPlayer

@export_subgroup("scenes")
@export var arena_scene:PackedScene;

@export var farm_scene:PackedScene;
@export var scrapyard_scene:PackedScene;
@export var factory_scene:PackedScene;

func _ready()->void:
	Entities.world_map = self;
	get_tree().paused = true;
	generate_world()


func _on_player_started_moving() -> void:
	$entities.process_mode = PROCESS_MODE_PAUSABLE


func _on_player_stopped_moving() -> void:
	$entities.process_mode = PROCESS_MODE_DISABLED;

func pause_map():
	## the built in pause functionality is used to control whether
	## the other parties are moving,
	## (eventually) the day/night cycle, global clock and everything tied to it
	
	## truly pausing the map includes disabling the player's navigation
	## (when there's a menu open)

	process_mode = PROCESS_MODE_DISABLED
	Entities.in_map_player.process_mode = Node.PROCESS_MODE_DISABLED;
	
func unpause_map():
	process_mode = PROCESS_MODE_PAUSABLE
	Entities.in_map_player.process_mode = Node.PROCESS_MODE_ALWAYS;


func generate_world():
	var alternatives = [farm_scene, scrapyard_scene, factory_scene];
	for i in 10:
		var settlement_name:String = NameDatabase.generate_name();
		var settlement:Settlement = alternatives.pick_random().instantiate();
		print(settlement)
		var location = Vector2(randi_range(0, 1000), randi_range(0, 1000));
		print(location)
		
		settlement.position = location;
		settlement.name = settlement_name;
		add_child(settlement);
		
