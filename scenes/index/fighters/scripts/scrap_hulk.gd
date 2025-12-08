extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var damage:String = Index.colored_text("attack", unit.final_stat("attack"), " damage");
	var base_count:float = skill.base_special_values["shrapnel_count"];
	var t:float = unit.final_stat("technique")
	var shrapnel_count:int = int(Scaling.technique_scaled_value(base_count, t, "", .2));
	
	var final_string:String = "Slams the ground, dealing %s to enemies in an area and fires %d shards of shrapnel in random directions that deal %s to enemies."%[damage, shrapnel_count, damage];
	return final_string;

func special_skill_effect()->void:
	var projectile_count:int = get_shrapnel();
	for p:int in projectile_count:
		var x_roll:float = randf_range(-1, 1);
		var y_roll:float = randf_range(-1, 1)
		var angle:= Vector2(x_roll, y_roll)
		projectile.shoot(angle)

func get_shrapnel()->int:
	var base_amount:int = skill.base_special_values["shrapnel_count"]
	return int(Scaling.technique_scaled_value(base_amount, fighter.technique, "", .5))
