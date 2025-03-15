extends Leader

@export var fighter_unit_scene:PackedScene;

@export var dialogue:DialogueResource;
@export var leader_unit:FighterUnit

const behavior = "agressive"

func _ready()->void:
	## prob just generates every time until load files
	## or like procedural generation
	generate();

func generate()->void:
	## generic map parties will be generated based on 
	## world conditions such as region and the player's level
	
	## probably make this reusable for other generic map parties
	var leader_base:FighterBase = Index.random_fighter_base()
	leader_unit.add_child(leader_base);
	leader_unit.base = leader_base
	
	leader_unit.level = 5;
	leader_unit.load_stats()
	
	#for i in randi_range(1, 2):
		#var fighter:FighterUnit = fighter_unit_scene.instantiate();
		#
		#var base:FighterBase = Index.random_fighter_base()
		#fighter.base = base;
		#fighter.add_child(base);
#
		#fighter.level = randi_range(3, 5);
		#fighter.load_stats()
		#
		#roster.add_child(fighter);
