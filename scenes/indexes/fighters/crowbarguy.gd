extends FighterBase


const skill_effects = ["direct_damage"];
const skill_visuals = ["lunge_forward", "recoil_target"]

const target_type = "nearest_enemy"


const skill_name =  "Crowbar Swing"
const short_description = "Surprisingly strong for a scientist with a crowbar."
const long_description = "Low resistance and range, high damage.\n
Can be upgraded to deal heavy damage or to apply heavy crowd control."


const tags = [
	"hunter",
	"scientist"
]

const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 100;

const debuff_type = "stat";
const skill_cooldown = 1;

const stats_to_debuff = ["defense"];
const stat_debuff_values = {
	"defense":5
}
