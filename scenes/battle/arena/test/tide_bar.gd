extends TextureProgressBar

@export var arena:Node2D;

@export var team_1:Team;
@export var team_2:Team;

@export var icon:TextureRect;

var total_levels_sum:int=0;
var t1_levels_sum:int = 0;
var t2_levels_sum:int = 0;


func _ready()->void:
	await arena.battle_started;
	max_value = 0;
	for fighter:ActiveFighter in team_1.units:
		total_levels_sum += fighter.level
		t1_levels_sum += fighter.level
	for fighter:ActiveFighter in team_2.units:
		total_levels_sum += fighter.level
		t2_levels_sum += fighter.level
	
	refresh_value()
	max_value = total_levels_sum;
	

func refresh_value()->void:
	max_value = total_levels_sum;
	value = t1_levels_sum
	

func _on_team_1_unit_died(unit: ActiveFighter) -> void:
	t1_levels_sum -= unit.level;
	total_levels_sum -= unit.level;
	refresh_value()

func _on_team_2_unit_died(unit: ActiveFighter) -> void:
	t2_levels_sum -= unit.level;
	total_levels_sum -= unit.level
	refresh_value()
