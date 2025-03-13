extends FighterBase


const skill_effects = ["aoe_damage", "aoe_debuff"];
const skill_visuals = ["lunge_forward", "shrink_target"]

const target_type = "nearest_enemy"


const skill_name = "Rusty Pipe"
const description = "Moderate resistance and damage, attacks reduce enemies' damage."
const long_description = "Disruptive and resistant. Can be upgraded to become extremely resistant or to deal great AOE damage."

func full_skill_description(unit:FighterUnit)->String:
	var damage_str = Meta.get_unit_damage_string(unit);
	var atk_reduction_str=  Meta.get_technique_scaled_string(unit, "", stat_debuff_values.attack, "%");
	
	var str:String = "Deals " + damage_str + " damage to enemies in an area and reduces their attack by "\
	+atk_reduction_str + " for the rest of the battle.";
	return str;

const tags = [
	"brawler",
	"mechanic"
]

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;

const skill_range = 100;
const skill_cooldown = 3;

const debuff_type = "stat";

const stats_to_debuff = ["attack"];
const stat_debuff_values = {
	"attack":5
}
