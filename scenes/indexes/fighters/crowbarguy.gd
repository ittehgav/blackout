extends FighterBase


const skill_effects = ["direct_damage"];
const skill_visuals = ["lunge_forward", "recoil_target"]

const target_type = "nearest_enemy"


const skill_name =  "Crowbar Swing"
const description = "Not very resistant. Surprisingly strong for a scientist with a crowbar."
const long_description = "Low resistance and range, high damage.\n
Can be upgraded to deal heavy damage or to apply heavy crowd control."

func full_skill_description(unit:FighterUnit)->String:
	var damage_str = Meta.get_unit_damage_string(unit);
	var technique_str = Meta.get_technique_scaled_string(unit)
	
	var final_damage = unit.stats.attack * unit.stats.technique;
	var final_damage_color = Meta.stat_colors.attack.blend(Meta.stat_colors.technique).to_html();
	var final_damage_str = "[color=" + final_damage_color + "]" + str(final_damage) + "[/color]"
	
	var string:String = "Deals " + damage_str + " * " + \
	technique_str + " (" + final_damage_str + ") damage to the nearest enemy.";
	return string;


const tags = [
	"hunter",
	"scientist"
]

func damage_modifier(damage:float)->float:
	return damage * fighter.technique;

const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 100;

const debuff_type = "stat";
const skill_cooldown = 1;

const stats_to_debuff = ["defense"];
const stat_debuff_values = {
	"defense":5
}
