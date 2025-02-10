extends Node2D

class_name WorldMap

@export var player:InMapPlayer

func _ready()->void:
	Entities.world_map = self;

func _on_player_started_moving() -> void:
	$entities.process_mode = PROCESS_MODE_PAUSABLE


func _on_player_stopped_moving() -> void:
	$entities.process_mode = PROCESS_MODE_DISABLED;
