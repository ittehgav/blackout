extends Node2D

class_name Team;

signal unit_died(unit:ActiveFighter)
## to make it easier for the tide bar to tell the team
signal all_units_loaded

@export var arena:Node2D

@export var team_n:int;
@export var enemy_team:Team;
@export var projectiles:Node2D;

var leader_fighter:ActiveFighter
var leader:Leader;

var units:Array[ActiveFighter];

func assign_unit(unit:ActiveFighter)->void:
	units.append(unit);
	unit.ally_team = self;
	unit.enemy_team = enemy_team;
	
	
	await unit.ready;
	unit.death.connect(on_unit_death.bind(unit))

	unit.set_collision_layer_value(team_n, true);
	if not unit is PlayerFighter:
		unit.get_node("skill_range").set_collision_mask_value(enemy_team.team_n, true);
		if unit.base.hit_scan:
			if Entities.player_fighter in units:
				unit.base.hit_scan.get_node("projection").hide();
			unit.base.hit_scan.set_collision_mask_value(enemy_team.team_n, true);
	ColorCoder.color_code_fighter(unit.base, team_n)



func _on_child_entered_tree(node: Node) -> void:
	assert(node is ActiveFighter)
	assign_unit(node)

func on_unit_death(_killer:ActiveFighter, unit:ActiveFighter)->void:
	unit_died.emit(unit)
