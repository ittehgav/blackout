extends Panel


@export_subgroup("Levels")
@export var leadership_level_label:Label;
@export var leadership_level_progress:ExperienceBar;

@export var combat_level_label:Label;
@export var combat_level_progress:ExperienceBar;





@export_subgroup("Combat Stats")
@export var max_hp_label:Label;
@export var attack_label:Label;
@export var defense_label:Label;
@export var agility_label:Label;
@export var technique_label:Label;

func refresh_data()->void:
	leadership_level_label.text = "Leadership Level: " + str(Entities.player.leadership_level);
	combat_level_label.text = "Combat Level: " + str(Entities.player.combat_level);
	
	leadership_level_progress.build_from_player("leadership")
	combat_level_progress.build_from_player("combat")
	
	var player_stats:CombatStats = Entities.player.combat_stats;
	for stat:String in Index.all_combat_stats:
		self[stat+"_label"].text = stat.capitalize() + ": " + str(player_stats[stat]);
