extends Node2D

class_name FighterUnit

signal level_up;
## fighter bases dont need to be loaded for each individual Fighter node
@export var base:FighterBase;

@export var level:int=1;
@export var experience:int=0;

## remaining downed time in in-game minues
var remaining_downed_minutes:int=0;

@export var stats:CombatStats;

func _ready()->void:
	if base:
		await get_parent().get_parent().ready;
		load_stats();
	level_up.connect(Scaling.level_up_stats)


func load_stats()->void:
	## runs as the fighter is instantiated
	## stats are only changeable by levels and 
	## gear (?)
		
	Scaling.initiate_unit_stats(self);
	Scaling.level_up_stats(self, level)

func downed()->void:
	## only effectively applies after battle
	remaining_downed_minutes = 24 * 60
	Entities.world_map.minute_passed.connect(downed_time_passed)
	
func downed_time_passed()->void:
	remaining_downed_minutes -= 1;
	if not remaining_downed_minutes:
		Entities.world_map.minute_pased.disconnect(downed_time_passed)

func final_skill_cooldown(agi_acm:float=stats.agility)->float:
	var cooldown:float = base.skill_cooldown;

	while agi_acm > 5:
		cooldown -= cooldown/20;
		agi_acm -= 5;
	
	var final_reduction:float = (cooldown/100)*agi_acm
	cooldown -= final_reduction
	return cooldown
