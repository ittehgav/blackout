extends Panel


@export_subgroup("Levels")
@export var leadership_level_label:Label;
@export var leadership_level_progress:TextureProgressBar;

@export var combat_level_label:Label;
@export var combat_level_progress:TextureProgressBar;





@export_subgroup("Combat Stats")
@export var max_hp_label:Label;
@export var attack_label:Label;
@export var defense_label:Label;
@export var agility_label:Label;
@export var technique_label:Label;

func refresh_data():
	leadership_level_label.text = "Leadership Level: " + str(Entities.player.leadership_level);
	combat_level_label.text = "Combat Level: " + str(Entities.player.combat_level);

	leadership_level_progress.max_value = Scaling.exp_for_next_level(Entities.player.leadership_level);
	leadership_level_progress.value = Entities.player.leadership_exp;

	combat_level_progress.max_value = Scaling.exp_for_next_level(Entities.player.combat_level);
	combat_level_progress.value = Entities.player.combat_exp;
	

	#var cstats:CombatStats = Entities.player.combat_stats;
#
	#max_hp_label.text = "Max HP: " + str(cstats.max_hp);
	#attack_label.text = "Base Attack: " + str(cstats.attack);
	#defense_label.text = "Defense: " + str(cstats.defense);
	#agility_label.text=  "Agility: " + str(cstats.agility);
	#technique_label.text = "Technique: " + str(cstats.technique);
	
