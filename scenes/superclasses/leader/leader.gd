extends Node

class_name Leader

@onready var color_scheme_index:int = randi_range(0, len(Index.color_schemes) - 1);


@export var inventory:Inventory;
@export var roster:Roster;
@export var combat_stats:CombatStats;

@export var sight_range:int;

@onready var party_name:String = name;

func generate_fighter(unit:FighterUnit, team_n:int)->ActiveFighter:
	var fighter:NpcFighter = Index.npc_fighter_scene.instantiate();
	Entities.arena.tide_bar["team_" + str(team_n) + "_unit_values"][fighter] = unit.level;
	
	fighter.load_fighter(unit, team_n==1);
	
	Entities.arena.assign_team(fighter, team_n, self);
	if team_n == 2:
		if unit == self["leader_unit"]:
			fighter.ally_team.leader = self;
			fighter.ally_team.leader_fighter = fighter
	
	ColorCoder.color_code_fighter(fighter.base, color_scheme_index);
	
	if "projectile" in fighter.base:
		fighter.base.projectile.setup(fighter);
	
	fighter.base.flip_h = team_n == 2
	return fighter;
	
	

func load_party(team:Team, team_n:int)->void:
	var cols:Dictionary={"melee":[], "mid":[], "long":[]}

	for unit:FighterUnit in roster.units:
		var fighter:ActiveFighter= generate_fighter(unit, team_n);
		
		if unit.base.skill_range == FighterBase.MELEE_RANGE:
			cols.melee.append(fighter)
		elif unit.base.skill_range < 750:
			cols.mid.append(fighter)
		else:
			cols.long.append(fighter)
		team.add_child(fighter);

	var base_x:int = 250;
	if team_n == 1:
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
