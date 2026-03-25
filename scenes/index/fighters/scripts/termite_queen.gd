extends FighterBase

@export var termite_unit:FighterUnit
var first_summon:bool=true;

func full_skill_description(_unit:FighterUnit)->String:
	return "Spawns Termites, which self-detonate on enemies."


func special_skill_effect()->void:
	if first_summon:
		## simpler and less propagative than
		## to make this happen at battle start from
		## the base scipt
		termite_unit.level = fighter.level;
		termite_unit.update_stats();
		first_summon = false
		
	var x_roll:int = randi_range(-1, 1);
	while x_roll == 0:
		x_roll = randi_range(-1, 1)
	var y_roll:int = randi_range(-1 , 1);
	while y_roll == 0:
		y_roll = randi_range(-1, 1)
		
	var target_position:Vector2 = fighter.position + Vector2(x_roll, y_roll) * Entities.arena.grid.tile_set.tile_size.x
	
	fighter.ally_team.generate_fighter(termite_unit, target_position)


	

	
