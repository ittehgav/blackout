extends Node

class_name Leader

@onready var npc_fighter_scene:PackedScene = preload("res://scenes/battle/npc_fighter/npc_fighter.tscn");

@export var inventory:Inventory;
@export var roster:Roster;
@export var combat_stats:CombatStats;

func load_party(team:Node2D)->Array[ActiveFighter]:
	var x_acm = 0;
	var y_acm = 0;
	var party:Array[ActiveFighter]
	for unit in roster.units:
		var npc_fighter:NpcFighter = npc_fighter_scene.instantiate();
		npc_fighter.fighter = unit;
		npc_fighter.load_fighter();
		
		npc_fighter.position = Vector2(x_acm, y_acm);
		y_acm += 100;
		if y_acm == 300:
			x_acm += 100;
			y_acm = 0;
		
		team.add_child(npc_fighter);
		party.push_back(npc_fighter);
	print(party)
	return party
