extends Node

class_name Fighter

## fighter bases are dont need to be loaded for each individual Fighter node
@export var base:FighterBase;

@export var level:int;
@export var experience:int;

@export var stats:CombatStats;

func _ready()->void:
	load_stats();
	

func load_stats():
	## runs as the fighter is instantiated
	## stats are onle changeable by levels and 
	## gear (?)
	Scaling.initiate_unit_stats(self);
	Scaling.level_up_stats(self)
		
