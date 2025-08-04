extends Panel

@export var name_label:Label;


@export_subgroup("Levels")
@export var level_label:Label;
@export var player_experience:ExperienceBar;





@export_subgroup("Combat Stats")
@export var max_hp_label:Label;
@export var attack_label:Label;
@export var defense_label:Label;
@export var agility_label:Label;
@export var technique_label:Label;

@export_subgroup("Disciplines")
@export var charisma_label:Label;
@export var navigation_label:Label;
@export var tactics_label:Label;
@export var leadership_label:Label;
@export var scavenging_label:Label;


func _ready()->void: 
	name_label.text = Entities.player.name

func refresh_data()->void:
	level_label.text = "Level: " + str(Entities.player.level)

	var player_stats:CombatStats = Entities.player.combat_stats;
	
	for stat:String in Index.all_combat_stats:
		self[stat+"_label"].text = stat.capitalize() + ": " + str(player_stats[stat]);
		
	for d:String in DisciplineTree.all_disciplines:
		self[d+"_label"].text = d.capitalize() + ": " + str(Entities.player.disciplines[d])
