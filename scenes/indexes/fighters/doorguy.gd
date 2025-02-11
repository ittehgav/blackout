extends FighterBase


const skill_effects = ["self_buff"];
const skill_visuals = ["recoil"]

const target_type = "nearest_enemy"

const skill_name = "Buckle up"
const short_description = "[color=blue]Doesn't deal damage.[/color] Shields self, becoming progressively more resistant."
const long_description = "Can be extremely difficult to take down."

const tags = [
	"juggernaut",
	"mechanic",
	"bodybuilder"
]

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;

const skill_range = 100;
const skill_cooldown = 3;

const buff_type = "stat";

const stats_to_buff = ["defense"]
const stat_buff_values = {
	"defense":5
}
