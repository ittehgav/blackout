extends FighterBase


const sample_offset = Vector2(13, -26)


const skill_name =  "Crowbar Swing"
const description = "Low resistance, high melee damage."
const flavor = "Surprisingly strong for just a scientist with a crowbar."

const evolutions = [
	"Sniper",
	"Gravity"
]

func full_skill_description(unit:FighterUnit)->String:
	var base_damage_str:String = Index.get_color_tag("attack") +  str(unit.stats.attack) + "[/color]";

	var final_damage_color_hex:String = Index.stat_colors.attack.blend(Index.stat_colors.technique).to_html();
	var final_damage_str:String = Index.get_unit_damage_string(unit);
	final_damage_str= "[color=" + final_damage_color_hex + "]" + final_damage_str + "[/color]"
	
	var technique_str:String = Index.get_color_tag("technique") + str(snapped(unit.stats.technique * Scaling.technique_mechanic_multipliers["damage"], .01)) + "[/color]"
	
	var string:String = "Deals " + final_damage_str + " ("+base_damage_str+" + " + base_damage_str + " * " + technique_str + ") to the nearest enemy.";

	string += "\n\nCan be upgraded to deal heavy, long-range damage or to apply AOE crowd control.";
	return string;


func damage_modifier(damage:float, unit:FighterUnit=null)->float:
	if not unit:
		return Scaling.technique_scaled_value(damage, fighter.technique, "damage")
	else:
		return Scaling.technique_scaled_value(damage, unit.stats.technique, "damage")

const skill_range = MELEE_RANGE;
const skill_cooldown = 2.5;


func skill()->void:
	Combat.set_windup_angle(fighter);
	
	animation_player.play("crowbar/skill");
	animation_player.queue("fighter_base/idle")
	
func skill_impact()->void:
	if fighter.dead:
		return;
	Combat.deal_damage(fighter);
	fighter.catch_hit_target(fighter.target_unit)
