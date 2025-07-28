extends MapParty;

class_name PlayerParty;

@export var marker:Sprite2D;

func _ready()->void:
	Entities.player_party = self;
	ColorCoder.color_code_vehicle(vehicle, leader)
	
	marker.show_in_settlement(current_settlement);

func intimidate_odds(target:NpcMapParty)->float:
	var combined_level:int = leader.combat_level * 2;
	for unit:FighterUnit in leader.roster.units:
		combined_level += unit.level;
		
	var target_combined_level:int = target.leader.leader_unit.level * 2;
	for unit:FighterUnit in target.leader.roster.units:
		target_combined_level += unit.level;
	
	var frac:float = float(combined_level)/float(target_combined_level);
	if frac >= 3.00:
		return 1.0;
	elif frac >= 2:
		## frac == 2 - odds = .9
		return frac * .45
	elif frac >= 1.75:
		## fract == 1.75 - odds = .8
		return frac * .8/1.75
	elif frac >= 1.5:
		## frac == 1.5 - odds = .7
		return frac * .7/1.5;
	elif frac >= 1.25:
		## frac == 1.25 - odds = .5
		return frac * .5/1.25
	elif frac >= 1.00:
		## frac == 1.00 - odds = .4
		return frac * .4
	elif frac >= .75:
		## frac == .75 - odds = .3
		return frac * .3/.75
	elif frac >= .5:
		## frac == .5 - odds = .2
		return frac * .2/.5;
	else:
		return 0;

func convince_odds(target:NpcMapParty)->float:
	var level_gap: = 0;
	var leadership_lvl_gap:int = leader.leadership_level - target.leader.leader_unit.level;
	var combat_lvl_gap:int = leader.combat_level - target.leader.leader_unit.level;
	
	if abs(leadership_lvl_gap) < abs(combat_lvl_gap):
		level_gap = abs(leadership_lvl_gap);
	else:
		level_gap = abs(combat_lvl_gap);
	
	var odds: = .8;
	odds += .1 * leader.leadership_stats.charisma
	var per_level_decay: = .8;
	per_level_decay += .025 * leader.leadership_stats.charisma;
	for i:int in level_gap:
		odds *= per_level_decay
	return odds
	
func roll_intimidate(target:NpcMapParty)->bool:
	var roll: = randf_range(0, 1);
	if roll < intimidate_odds(target):
		return true;
	else:
		return false

func roll_convince(target:NpcMapParty)->bool:
	var roll: = randf_range(0, 1);
	if roll < convince_odds(target):
		return true;
	else:
		return false;


func _on_started_moving() -> void:
	get_tree().paused = false;
	marker.clear();
	get_tree().call_group("all_settlements", "player_started_moving")


func _on_settlement_visited(settlement: Settlement) -> void:
	stopped_moving.emit();
	get_tree().call_group("all_settlements", "player_stopped_moving");


func _on_stopped_moving() -> void:
	get_tree().paused = true;
