extends Node2D

class_name Team;

signal unit_died(unit:ActiveFighter)
## to make it easier for the tide bar to tell the team
signal all_units_loaded

signal unit_converted(unit:ActiveFighter)

@export var roster:Roster;

@export var arena:Arena

@export var team_n:int;
@export var enemy_team:Team;
@export var projectiles:Node2D;

var leader_fighter:ActiveFighter
var leader:Leader;

var units:Array[ActiveFighter];



func load_roster()->void:
	var cols := {"melee":[], "mid":[], "long":[]};
	for unit:FighterUnit in roster.units:
		
		var fighter:NpcFighter = generate_fighter(unit);
		match unit.base.skill_range:
			FighterBase.MELEE_RANGE:
				cols.melee.append(fighter);
			FighterBase.MID_RANGE:
				cols.mid.append(fighter);
			FighterBase.LONG_RANGE:
				cols.long.append(fighter);
			_:
				assert(false);

		
	
	position_column(cols.melee, 1000, 200);
	position_column(cols.mid, 1200, 200);
	position_column(cols.long, 1500, 200)
	
func generate_fighter(unit:FighterUnit)->NpcFighter:
	var fighter:NpcFighter = Index.scenes.npc_fighter.instantiate();
	fighter.ally_team = self;
	fighter.load_fighter(unit);
	add_child.call_deferred(fighter)
	if not fighter.base.special:
		fighter.adjust_collisions();
		
	ColorCoder.color_code_fighter(fighter, team_n)
	return fighter

func position_column(col:Array, x_origin:int, y_origin:int)->void:
	const y_gap:int = 100;
	var col_gap:int = 50;
	const units_per_col = 5;
	
	if team_n == 1:
		x_origin *= -1
		col_gap *= -1;
		
	var col_count:int = 0;
	for i:int in len(col):
		var fighter:NpcFighter = col[i]
		fighter.position.x = x_origin + (col_count * col_gap);
		fighter.position.y = y_origin + (y_gap * ((i+1) % units_per_col))
		
		if i % units_per_col == 0:
			col_count += 1;
	


func assign_unit(unit:ActiveFighter)->void:
	units.append(unit);
	unit.enemy_team = enemy_team;
	
	unit.death.connect(on_unit_death.bind(unit))

	unit.set_collision_layer_value(team_n, true);
	if not unit is PlayerFighter:
		unit.get_node("skill_range").set_collision_mask_value(enemy_team.team_n, true);
		if unit.base.hit_scan:
			if Entities.player_fighter in units:
				unit.base.hit_scan.get_node("projection").hide();
			unit.base.hit_scan.set_collision_mask_value(enemy_team.team_n, true);
	
	


func unassign_unit(fighter:ActiveFighter)->void:
	units.erase(fighter);
	fighter.death.disconnect(on_unit_death);
	
	fighter.set_collision_layer_value(team_n, false);
	if fighter.base.hit_scan:
		## will just hide it if converted from enemy team
		## to playe team
		fighter.base.hit_scan.get_node("projection").show();
		fighter.base.hit_scan.set_collision_mask_value(enemy_team.team_n, false);

func convert_unit(unit:ActiveFighter)->void:
	enemy_team.unassign_unit(unit)

	unit.reparent(self);
	assign_unit(unit)



func _on_child_entered_tree(node: Node) -> void:
	if node not in units:
		## leave this on like this so i can just test 
		## by throwing nodes into the editor
		assert(node is ActiveFighter or node is NpcFighterTest);
		if node is ActiveFighter:
			assign_unit(node)

func on_unit_death(_killer:ActiveFighter, unit:ActiveFighter)->void:
	unit_died.emit(unit)
