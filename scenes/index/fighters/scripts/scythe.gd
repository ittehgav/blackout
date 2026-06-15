extends FighterBase

const evolution_names = ["Scrap Hulk", "Toxic Hulk"]

const base_per_target_heal = 15;

func full_skill_description(unit:FighterUnit)->String:
	var heal_string:String = str(Scaling.technique_scaled_value(base_per_target_heal, unit.final_stat("technique"), "heal"))
	var damage:String = Index.colored_text("attack", unit.final_stat("attack"), " damage");
	var final_string:String = "Deals %s to enemies in an area, heals self for %s for each enemy hit."%[damage, heal_string];
	return final_string;

func special_skill_effect()->void:
	var hit_targets:int = len(fighter.hit_targets);
	var per_target_healing:int = Scaling.technique_scaled_value(base_per_target_heal, fighter.technique, "heal")
	var total_healing:int = hit_targets * per_target_healing;
	Combat.heal_target(fighter, fighter, total_healing)
