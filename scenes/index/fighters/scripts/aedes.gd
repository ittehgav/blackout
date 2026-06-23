extends FighterBase

const lifesteal_frac = .1;
const lifesteal_technique_amp = .05

func full_skill_description(unit:FighterUnit)->String:
	var vamp_value:float = CombatStats.technique_scaled_value(lifesteal_frac, unit.final_stat("technique"), "", lifesteal_technique_amp);
	var vamp_string:String = Index.colored_text("technique", vamp_value, "%");
	var damage:String = Index.colored_text("attack", unit.final_stat("attack"), " damage");
	return "Deals %s damage to the nearest enemy and heals itself for %s% of the damage dealt."%[damage, vamp_string];
