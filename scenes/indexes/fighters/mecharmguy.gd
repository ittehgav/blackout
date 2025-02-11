extends FighterBase


const skill_effects = ["aoe_damage", "aoe_debuff"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const skill_name =  "Wrecking Punch"
const short_description = "Throws a powerful punch that reduces the defense of the target."
const long_description = "Can tear through even the toughest of enemies."

const tags = [
	"juggernaut",
	"cyborg",
	"brawler"
]

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;
const skill_range = 100;

const debuff_type = "stat";

const stats_to_debuff = ["defense"];
const stat_debuff_values = {
	"defense":5
}


const skill_cooldown = 3;
