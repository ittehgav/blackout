extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var vamp_value:float = Scaling.technique_scaled_value(skill.base_special_values["vamp"], unit.final_stat("technique"), "", .5);
	var vamp_string:String = Index.colored_text("technique", vamp_value, "%");
	var damage:String = Index.colored_text("attack", unit.final_stat("attack"), " damage");
	var final_string:String = "Deals %s to enemies in an arc area, heals self for %s of the damage dealt."%[damage, vamp_string];
	return final_string;
	
var total_vamp:int;
var vamp:float;
func special_skill_effect()->void:
	total_vamp = 0
	fighter.damage_dealt.connect(catch_vamp);
	vamp = Scaling.technique_scaled_value(skill.base_special_values["vamp"], fighter.technique, "", .5)/100;
	await skill.finished;
	Combat.heal_unit(fighter, fighter, total_vamp);
	fighter.damage_dealt.disconnect(catch_vamp);

func catch_vamp(damage:float, _target:ActiveFighter)->void:
	total_vamp += damage * vamp;
