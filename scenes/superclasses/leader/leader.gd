extends Node

class_name Leader



@export_group("Party Data")
@export var inventory:Inventory;
@export var roster:Roster;
@export var combat_stats:CombatStats;

@export var sight_range:int;
@export_group("Scenes")
@export var fighter_unit_scene:PackedScene
@export var npc_fighter_scene:PackedScene;

func load_party(team:Team, left_side:bool=true)->void:
	var party:Array[ActiveFighter]
	
	var cols:Dictionary={"melee":[], "mid":[], "long":[]}

	for unit:FighterUnit in roster.units:
		var fighter:NpcFighter = npc_fighter_scene.instantiate();
		team.add_child(fighter);
		fighter.load_fighter(unit);
		
		if unit.base.skill_range == FighterBase.MELEE_RANGE:
			cols.melee.append(fighter)
		elif unit.base.skill_range < 750:
			cols.mid.append(fighter)
		else:
			cols.long.append(fighter)
		
		party.push_back(fighter);
	
	var base_x = -250;
	if not left_side:
		base_x *= -1;
		
	const y_shift = 60;
	
	for i:int in len(cols.melee):
		var fighter:ActiveFighter = cols.melee[i]
		fighter.position.x = base_x;
		
		fighter.position.y = y_shift * i
	
		if i % 2:
			fighter.position.y *= -1;
			
	for i:int in len(cols.mid):
		var fighter:ActiveFighter = cols.mid[i];
		fighter.position.x = base_x * 2
		
		fighter.position.y = y_shift * i
	
		if i % 2:
			fighter.position.y *= -1;
			
	for i:int in len(cols.long):
		var fighter:ActiveFighter = cols.long[i];
		fighter.position.x = base_x * 4
		
		fighter.position.y = y_shift * i
	
		if i % 2:
			fighter.position.y *= -1;
		

	#for key in cols.keys():
		
