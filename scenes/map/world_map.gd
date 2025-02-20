extends Node2D

class_name WorldMap

@export var ui:Control;

@export var player:InMapPlayer

@export var arena_scene:PackedScene;

func _ready()->void:
	Entities.world_map = self;
	get_tree().paused = true;


func _on_player_started_moving() -> void:
	$entities.process_mode = PROCESS_MODE_PAUSABLE


func _on_player_stopped_moving() -> void:
	$entities.process_mode = PROCESS_MODE_DISABLED;

func pause_map():
	## the built in pause functionality is used to control whether
	## the other parties are moving,
	## truly pausing the map includes (eventually)
	## the day/night cycle, global clock and everything tied to it

	process_mode = PROCESS_MODE_DISABLED
	Entities.in_map_player.process_mode = Node.PROCESS_MODE_DISABLED;
	
func unpause_map():
	process_mode = PROCESS_MODE_PAUSABLE
	Entities.in_map_player.process_mode = Node.PROCESS_MODE_ALWAYS;
