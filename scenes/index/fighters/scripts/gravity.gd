extends FighterBase

@onready var knock_back_distance:int = hit_scan.get_node("shape").shape.size.x

func full_skill_description(unit:FighterUnit)->String:
	var stun_duration:String = Index.colored_text("technique", Scaling.technique_scaled_value(skill.status.duration, unit.final_stat("technique"), "stun")," seconds");
	
	var final_string:String = "Knocks back and stuns an enemy for %s, also stuns any enemies they collide with."%stun_duration;
	return final_string
