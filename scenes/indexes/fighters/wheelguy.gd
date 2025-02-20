extends FighterBase

const skill_effects = ["special"];
const skill_visuals = ["power_up_glow", "shake"]

const target_type = "nearest_enemy"

const skill_name =  "Accelerate"
const short_description = "Deals damage to surrounding enemies that speeds up over time."
const long_description = "Speeds up the wheel, making it deal damage to enemies faster."

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;
const skill_range = 100;

const tags = [
	"brawler",
	"hunter",
	"mechanic"
]

const skill_cooldown = 3;

func special_skill(fighter:ActiveFighter)->void:
	pass
