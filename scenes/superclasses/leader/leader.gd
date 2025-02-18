extends Node

class_name Leader

@export var inventory:Inventory;
@export var roster:Roster;
@export var combat_stats:CombatStats;

func load_party(team:Node2D)->Array[ActiveFighter]:
	var x_acm = 0;
	var y_acm = 0;
	var party:Array[ActiveFighter]

	if not self is Player:
		## make the leader of each party an operational fighter
		## higher level/class than subordinates?
		print("notp")

	for unit:FighterUnit in roster.units:
		var npc_fighter:NpcFighter = NpcFighter.new();
		npc_fighter.unit = unit;
		npc_fighter.load_fighter();
		
		npc_fighter.position = Vector2(x_acm, y_acm);
		y_acm += 100;
		if y_acm == 300:
			x_acm += 100;
			y_acm = 0;
		
		team.add_child(npc_fighter);
		party.push_back(npc_fighter);
	return party
