extends FighterBase

const skill_effects = ["aoe_damage"];
const skill_visuals = ["recoil", "recoil_target"]

const target_type = "nearest_enemy"


const skill_name = "Piercing Shot"
const description = "Fires a powerful, long-range piercing bolt."
const long_description = "Deals massive damage to enemies in a straight line."

func damage_modifier(damage:float)->float:
	return damage * fighter.technique;

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Meta.get_unit_damage_string(unit);
	var technique_str:String = Meta.get_technique_scaled_string(unit);
	
	var final_damage:float = unit.stats.attack * unit.stats.technique;
	var final_damage_color_hex:String = Meta.stat_colors.attack.blend(Meta.stat_colors.technique).to_html();
	var final_damage_str:String = "[color=" + final_damage_color_hex + "]" + str(final_damage) + "[/color]"
	
	var string:String = "Deals " + damage_str + " * " + technique_str + " ("+final_damage_str + ") damage to enemies in a straight line.";
	return string;

const tags = [
	"hunter",
	"ranger",
	"doctor"
]


const hit_scan_type = "line";
const hit_scan_length = 2000.0;

const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = 750;

const skill_cooldown = 3;
