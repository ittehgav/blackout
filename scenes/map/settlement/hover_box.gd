extends Control

func _ready()->void:
	Entities.world_map.map_paused.connect(hide)
	Entities.world_map.map_unpaused.connect(show)
