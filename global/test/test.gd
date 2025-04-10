extends Node

@onready var fighter_unit_scene:PackedScene = load("res://scenes/battle/fighter/fighter_unit.tscn")

@onready var player_scene:PackedScene = load("res://scenes/player/player.tscn")
@onready var tailpipe_scene:PackedScene = load("res://scenes/indexes/items/weapons/tailpipe.tscn");

@onready var thugs_scene:PackedScene = load("res://scenes/indexes/parties/generic/thugs.tscn");

func generate_leader(parent:Node)->Leader:
	var leader:Leader = thugs_scene.instantiate();
	leader.generate();
	parent.add_child(leader)
	return leader


func fill_party(roster:Roster, amount:int = 5, max_level:int = 10)->void:
	for i in amount:
		var base:FighterBase = Index.random_fighter_base();
		
		var fighter:FighterUnit = fighter_unit_scene.instantiate();
		fighter.level = randi_range(0, max_level);
		fighter.base = base;
		roster.add_child(fighter);
	
