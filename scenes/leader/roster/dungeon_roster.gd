extends Roster

class_name DungeonRoster

func generate_units(target_level:int)->void:
	clear_units()
	
	var amount:int = max(5, randi_range(target_level/5, 5));
	for i:int in amount:
		var center:int = target_level/amount - 2
		var unit_level:int = randi_range(center - 2, center + 2 );
		
		var base:FighterBase = Index.fighters.all_fighter_bases.pick_random()
		if unit_level < 5:
			while len(base.tags) > 2:
				base = Index.fighters.all_fighter_bases.pick_random();
		
		
		var unit:FighterUnit = Index.scenes.fighter_unit.instantiate();
		unit.level = unit_level;
		unit.base = base
		unit.setup()
		add_unit(unit)
