extends FighterBase

const skill_effects = ["aoe_damage", "aoe_stun"];
const skill_visuals = ["lunge_forward"]

const skill_use_sfx = ["swing"]
const skill_hit_sfx = ["slam"]

## offset to be used on sprite samples
const sample_offset = Vector2(19, -42);

const target_type = "nearest_enemy"

const skill_name = "Throw Hands"
const description = "Slow and tough, damages and stuns enemies in an area."

func full_skill_description(unit:FighterUnit)->String:
	var damage:String = Meta.get_unit_damage_string(unit);
	var stun_duration_str:String = Meta.get_technique_scaled_string(unit, "stun_duration")
	
	var string:String = "Punches forward, dealing " + damage + \
	" damage and to enemies in a small area and stunning them for "\
	 + stun_duration_str + " seconds.";

	string += "\n\nCan be upgraded to deal much more damage or to apply crowd control over a large area."
	return string;

const tags = [
	"brawler",
	"bodybuilder"
]

const hitbox_radius = 30;
const hitbox_height = 80;
const hitbox_offset = Vector2(0, 10)

const hit_scan_radius = 100;

const skill_range = MELEE_RANGE;
const skill_cooldown = 5;

const status_duration = .125;
