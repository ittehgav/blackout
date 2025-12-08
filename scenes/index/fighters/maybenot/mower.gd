extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var trail_dps:String = Index.colored_text("attack", unit.technique_scaled_value(unit.final_stat("attack"), unit.final_stat("technique"), "", .25), " damage");
	var impact_damage:String = Index.colored_text("attack", unit.attack, " damage");
	var final_string:String = "Rides the mower across enemies in a straight line, dealing %s to enemies they collied with and leaving a fire trail that deals %d per second to eneies standing in it."%[impact_damage, trail_dps];
	return final_string;

func special_skill_effect()->void:
	fighter.movement_overriden = true;
	var target_coords:Vector2 = fighter.position + fighter.target_unit.position
