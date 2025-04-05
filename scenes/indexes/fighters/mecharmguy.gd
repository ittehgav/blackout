extends FighterBase


const skill_effects = ["aoe_damage", "aoe_stat_debuff"];
const skill_visuals = ["lunge_forward", "shrink_target"]

const skill_use_sfx = ["swing"]
const skill_hit_sfx = ["metal"]

const sample_offset = Vector2(25, -26)

const target_type = "nearest_enemy"

const skill_name =  "Wrecking Punch"
const description = "Throws a powerful punch that reduces the defense of the target."
const long_description = "Can tear through even the toughest of enemies."

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Meta.get_unit_damage_string(unit);
	var def_reduction_str:String = Meta.get_technique_scaled_string(unit, "poo", stat_debuff_values.defense);
	var string:String = "Deals "+damage_str + " damage to enemies in an area and reduces their"+Meta.get_color_tag("defense")+\
	" defense[/color] by "+  def_reduction_str + " for the rest of the battle.";
	return string;

const tags = [
	"juggernaut",
	"cyborg",
	"brawler"
]

const hitbox_radius = 35;
const hitbox_height = 100;
const hitbox_offset = Vector2.ZERO;

const hit_scan_radius = 100;
const skill_range = MELEE_RANGE;

const debuff_type = "stat";

const stats_to_debuff = ["defense"];
const stat_debuff_values = {
	"defense":5
}


const skill_cooldown = 3;
