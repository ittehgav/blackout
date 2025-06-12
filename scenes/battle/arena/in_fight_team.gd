extends Node2D

class_name Team;

signal all_units_loaded


@export var team_n:int;
@export var enemy_team:Team;

var initial_party_size:int
var leader_fighter:ActiveFighter
var leader:Leader;

var units:Array[Node];

func assign_unit(unit:ActiveFighter)->void:
	unit.ally_team = self;
	units.append(unit);
	unit.enemy_team = enemy_team;
