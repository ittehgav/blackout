extends FighterBase

@export var ticker:Timer;

const attack_scaling = .25

const acceleration = .1
const acceleration_technique_amp = .1

func full_skill_description(unit:FighterUnit)->String:
	var base_dps:String = Index.colored_text("attack", unit.final_stat("attack")*attack_scaling, " damage per second.");
	var final_accel:float = Scaling.technique_scaled_value(acceleration, unit.final_stat("technique"), "", acceleration_technique_amp);
	var accel_string:String = Index.colored_text("technique", final_accel, "%");
	var final_string:String = "Spins the wheel, dealing %s, each additional activation increases the damage speed by %s."%[base_dps, accel_string];
	return final_string

func special_skill_effect()->void:
	if not ticker.is_stopped():
		var reduction_frac:float = Scaling.technique_scaled_value\
		(acceleration, fighter.technique, "",acceleration_technique_amp ) ;
		ticker.wait_time -= ticker.wait_time * reduction_frac;
	else:
		ticker.start()

func _on_ticker_timeout() -> void:
	Combat.aoe_damage(fighter);
	
func damage_modifier(damage:float, _unit:ActiveFighter)->float:
	return damage * attack_scaling
