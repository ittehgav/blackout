extends FighterBase

const skill_effects = ["aoe_damage"];
const skill_visuals = ["recoil", "recoil_target"]

const target_type = "nearest_enemy"


const skill_name = "Piercing Shot"
const short_description = "Fires a powerful piercing bolt."
const long_description = "Deals massive damage to enemies in a straight line."

const tags = [
	"hunter",
	"ranger",
	"doctor"
]


const hit_scan_type = "line";
const hit_scan_length = 2000.0;

const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 1000;

const skill_cooldown = 3;
