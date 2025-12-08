extends FighterBase

@export var ticker:Timer;
const technique_scaling = .5
const attack_scaling = .25
func full_skill_description(unit:FighterUnit)->String:
	var base_dps:String = Index.colored_text("attack", unit.final_stat("attack")*attack_scaling, " damage per second.");
	var acceleration:float = Scaling.technique_scaled_value(skill.base_special_values["acceleration"], unit.final_stat("technique"), "", technique_scaling);
	var accel_string:String = Index.colored_text("technique", acceleration, "%");
	var final_string:String = "Spins the wheel, dealing %s, each additional activation increases the damage speed by %s."%[base_dps, accel_string];
	return final_string

func special_skill_effect()->void:
	if not ticker.is_stopped():
		var reduction_frac:float = Scaling.technique_scaled_value(skill.base_special_values["acceleration"], fighter.technique, "",technique_scaling )/100 ;
		ticker.wait_timer -= ticker.wait_time * reduction_frac;
	else:
		ticker.start()

func _on_ticker_timeout() -> void:
	Combat.aoe_damage(fighter);
	
func damage_modifier(damage:float, _unit:FighterUnit=null)->float:
	return damage * attack_scaling
