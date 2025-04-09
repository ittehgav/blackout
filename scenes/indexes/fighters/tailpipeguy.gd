extends FighterBase

const skill_windup = true;

const skill_effects = ["aoe_damage", "aoe_stat_debuff"];
const skill_visuals = ["lunge_forward", "shrink_target"]

const skill_use_sfx = ["swing"]
const skill_hit_sfx = ["metal"]

const sample_offset = Vector2(5, -26)

const target_type = "nearest_enemy"


const skill_name = "Rusty Pipe"
const description = "Moderate resistance and damage, attacks reduce enemies' damage."
const long_description = "Disruptive and resistant. "

func full_skill_description(unit:FighterUnit)->String:
	var damage_str: = Meta.get_unit_damage_string(unit);
	var atk_reduction_str:String =  Meta.get_technique_scaled_string(unit, "", stat_debuff_values.attack,1, "%");
	
	var string:String = "Deals " + damage_str + " damage to enemies in an area and reduces their "+Meta.get_color_tag("attack") + \
	"attack [/color]by " + atk_reduction_str + " for the rest of the battle.";
	string += "\n\nCan be upgraded to become extremely resistant or to deal great AOE damage."
	return string;

const tags = [
	"brawler",
	"mechanic"
]

const hitbox_radius = 40;
const hitbox_height = 100;
const hitbox_offset = Vector2(0, -5)

const hit_scan_radius = 100;

const skill_range = MELEE_RANGE;
const skill_cooldown = 3;

const debuff_type = "stat";

const stats_to_debuff = ["attack"];
const stat_debuff_values = {
	"attack":5
}
