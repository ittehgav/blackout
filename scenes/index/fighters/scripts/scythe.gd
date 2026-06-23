extends FighterBase

const evolution_names = ["Scrap Hulk", "Toxic Hulk"]

const base_per_target_heal = 15;

func full_skill_description(unit:FighterUnit)->String:
	var frac_heal:float = CombatStats.technique_scaled_value(base_per_target_heal, unit.final_stat("technique"), "heal");
	var percentage_str:String = str(frac_heal * 100)+"%"
	var final_string:String = "Deals damage to enemies in front of him and sends them flying a short distance, heals himself for %s % of the damage dealt."%percentage_str
	return final_string;

func special_skill_effect()->void:
	var hit_targets:int = len(fighter.hit_targets);
	var per_target_healing:int = CombatStats.technique_scaled_value(base_per_target_heal, fighter.technique, "heal")
	var total_healing:int = hit_targets * per_target_healing;
	Combat.heal_target(fighter, fighter, total_healing)
