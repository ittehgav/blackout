extends FighterBase

const skill_name = "Piercing Shot"
const description = "Fires a powerful, long-range piercing bolt."
const flavor = "One time he tried to use hot metal bars as arrows and got a second-degree burn."

const skill_range = LONG_RANGE;

const skill_cooldown = 3;


func damage_modifier(damage:float, unit:FighterUnit=null)->float:
	if not unit:
		return Scaling.technique_scaled_value(damage, fighter.technique, "damage")
	else:
		return Scaling.technique_scaled_value(damage, unit.stats.technique, "damage")

		
func full_skill_description(unit:FighterUnit)->String:
	var base_damage_str:String = Index.get_color_tag("attack") + str(unit.stats.attack) + "[/color]";

	var final_damage_color_hex:String = Index.stat_colors.attack.blend(Index.stat_colors.technique).to_html();
	var final_damage_str:String = Index.get_unit_damage_string(unit);
	
	final_damage_str = "[color=" + final_damage_color_hex + "]" + final_damage_str + "[/color]"
	
	var technique_str:String = Index.get_color_tag("technique") + str(snapped(unit.stats.technique * Scaling.technique_mechanic_multipliers["damage"], .01)) + "[/color]"
	
	var string:String = "Deals "+ final_damage_str +" ("+base_damage_str + " + " + base_damage_str \
	+ " * " + technique_str + ") to enemies in a long, straight line.";
	return string;



func skill()->void:
	Combat.set_windup_angle(fighter)
	Combat.set_aoe_aim(fighter)
	animation_player.play("crossbow/skill");
	animation_player.queue("fighter_base/idle");

func skill_impact()->void:
	if fighter.dead:
		return;
	Combat.aoe_damage(fighter, hit_scan, damage_modifier);
	skill_finished.emit();
