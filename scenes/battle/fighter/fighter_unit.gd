extends Node2D

class_name FighterUnit

## fighter bases are dont need to be loaded for each individual Fighter node
@export var base:FighterBase;

@export var level:int=1;
@export var experience:int=0;

@export var stats:CombatStats;

func _ready()->void:
	if base:
		load_stats();
	

func load_stats():
	## runs as the fighter is instantiated
	## stats are only changeable by levels and 
	## gear (?)
	Scaling.initiate_unit_stats(self);
	Scaling.level_up_stats(self)
