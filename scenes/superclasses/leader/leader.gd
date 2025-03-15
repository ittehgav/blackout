extends Node

class_name Leader


@export var inventory:Inventory;
@export var roster:Roster;
@export var combat_stats:CombatStats;

@export var sight_range:int;

func load_party(team:Team, npc_fighter_scene:PackedScene, x_offset:int=0)->void:
	var x_acm:int = 0;
	var y_acm:int = 0;
	var party:Array[ActiveFighter]


	for unit:FighterUnit in roster.units:
		var npc_fighter:NpcFighter = npc_fighter_scene.instantiate();
		team.add_child(npc_fighter);
		npc_fighter.load_fighter(unit);
		
		npc_fighter.position = Vector2(x_acm + x_offset, y_acm);
		y_acm += 100;
		if y_acm == 300:
			x_acm += 100;
			y_acm = 0;
		
		party.push_back(npc_fighter);
