extends FighterBase

@export var smoke:CPUParticles2D

func full_skill_description(unit:FighterUnit)->String:
	var final_string:String = "Shoots toxic gas on enemies in front of him, damaging them, sending them flying and applying a defense debuff.";
	return final_string


func _on_gas_leak_impact() -> void:
	smoke.set_emitting(true)
