extends Leader

class_name NpcLeader;

@export var dialogue:DialogueResource;
@export var unit:FighterUnit


func generate(distance:float)->void:
	## generic map parties will be generated based on 
	## world conditions such as region and the player's level
	
	## probably make this reusable for other generic map parties
	var leader_base:FighterBase = Index.random_fighter_base()
	unit.level = 5;
	unit.base = leader_base
	unit.add_child(leader_base);
	
	unit.load_stats()
	
	
	var max_level:int = distance/80;
	var min_level:int = max_level/2
	
	var party_size = distance/100;
	
	for i in party_size:
		var unit_base:FighterBase = Index.random_fighter_base();
		var new_unit:FighterUnit = fighter_unit_scene.instantiate();
		new_unit.level = randi_range(min_level, max_level);
		new_unit.add_child(unit_base)
		new_unit.base = unit_base;
		
		roster.add_child(new_unit)
