extends FighterBase

@export var dmg_timer:Timer;

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

const hit_scan_type = "surrounding";

const skill_cooldown = 3;

func _ready():
	dmg_timer.timeout.connect(aoe_damage.bind(get_parent()));

func special_skill(fighter:ActiveFighter)->void:
	if not dmg_timer.is_stopped():
		dmg_timer.wait_time -= dmg_timer.wait_time/10;
	else:
		dmg_timer.start();

func aoe_damage(unit:ActiveFighter) -> void:
	Combat.aoe_damage(unit)
