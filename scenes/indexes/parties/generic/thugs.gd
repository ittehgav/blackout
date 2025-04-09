extends Leader


@export var dialogue:DialogueResource;
@export var unit:FighterUnit

const behavior = "agressive"



func generate()->void:
	## generic map parties will be generated based on 
	## world conditions such as region and the player's level
	
	## probably make this reusable for other generic map parties
	var leader_base:FighterBase = Index.random_fighter_base()
	unit.level = 5;
	unit.base = leader_base
	unit.add_child(leader_base);
	
	unit.load_stats()
	
	for i in randi_range(3, 10):
		var unit_base:FighterBase = Index.random_fighter_base();
		var new_unit:FighterUnit = fighter_unit_scene.instantiate();
		new_unit.level = randi_range(1, 3);
		new_unit.add_child(unit_base)
		new_unit.base = unit_base;
		
		roster.add_child(new_unit)
