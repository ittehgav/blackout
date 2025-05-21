extends FighterBase

const skill_effects = ["aoe_damage"];
const skill_visuals = ["recoil", "recoil_target"]

const skill_use_sfx = ["shoot"]
const skill_hit_sfx = ["projectile_hit"]


const sample_offset = Vector2(11, -26)

const target_type = "nearest_enemy"

const skill_name = "Piercing Shot"
const description = "Fires a powerful, long-range piercing bolt."
const flavor = "One time he tried to use hot metal bars as arrows and got a second-degree burn."

const tags = [
	"hunter",
	"scientist",
	"doctor"
]


func damage_modifier(damage:float, unit:FighterUnit=null)->float:
	if not unit:
		if fighter.technique >= 2:
			return damage * fighter.technique/2;
		else:
			return damage
	else:
		if unit.stats.technique >= 2:
			return damage * unit.stats.technique/2;
		else:
			return damage
		
func full_skill_description(unit:FighterUnit)->String:
	var base_damage_str:String = Index.get_color_tag("attack") +  str(unit.stats.attack) + "[/color]";

	var final_damage_color_hex:String = Index.stat_colors.attack.blend(Index.stat_colors.technique).to_html();
	var final_damage_str:String = Index.get_unit_damage_string(unit);
	final_damage_str= "[color=" + final_damage_color_hex + "]" + final_damage_str + "[/color]"
	
	var technique_str:String = Index.get_technique_scaled_string(unit, "", 0, .5);
	
	var string:String = "Deals "+ final_damage_str + " (" + base_damage_str + " * " + technique_str + ") to enemies in a straight line.";
	return string;



const hit_scan_type = "line";
const hit_scan_length = 2000.0;

const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = 750;

const skill_cooldown = 15;
