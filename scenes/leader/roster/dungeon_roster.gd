extends Roster

class_name DungeonRoster

@export var loot:LootInventory

func generate_units(target_level:int)->void:
	clear_units()
	
	while get_level() < target_level:
		var center:int = target_level/10
		var unit_level:int = randi_range(center - 2, center + 2 );
		
		var base:FighterBase = Index.fighters.random_fighter_base()
		if unit_level < 5:
			base = Index.fighters.random_fighter_base(true);
		
		
		
		var unit:FighterUnit = Index.scenes.fighter_unit.instantiate();
		unit.level = unit_level;
		unit.base = base
		unit.setup()
		add_unit(unit)
	## need to generate loot after units are added and the roster has a levelss


func get_danger_level()->int:
	var frac:float = get_level()/Entities.player.get_party_level()
	if frac <= .5:
		return 1;
	elif frac < .75:
		return 2;
	elif frac <= 2:
		return 3;
	else:
		return 4
	
