extends FighterBase


const skill_effects = ["stun", "direct_damage"];
const skill_visuals = ["recoil"]

const target_type = "nearest_enemy"

const tags = [
	"disruptor",
	"scientist"
]

const skill_name = "Taser Shot"
const short_description = "Deals light damage and stuns target."
const long_description = "Utility unit.\nCan be upgraded to heal allies or for heavy AOE damage."


const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 500;
const skill_cooldown = 1;

const stun_duration = .75
