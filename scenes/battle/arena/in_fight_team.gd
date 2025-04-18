extends Node2D

class_name Team;

signal all_units_loaded


@export var team_n:int;
@export var enemy_team:Team;

var initial_party_size:int
var leader_fighter:ActiveFighter
var leader:Leader;

var units:Array[Node];


func _on_child_entered_tree(unit: Node) -> void:
	assert(unit is ActiveFighter)

	units.append(unit)
	unit.ally_team = self;
	unit.enemy_team = enemy_team;
	if len(units) == initial_party_size:
		all_units_loaded.emit();
