extends FighterBase

const skill_effects = ["aoe_damage", "aoe_stun"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const skill_name = "Throw Hands"
const description = "Slow and tough, damages and stuns enemies in an area."

const long_description = "Packs a decent punch, but takes a long time between attacks.\n
Can be upgraded for more crowd control and resistance or for more damage."

func full_skill_description(unit:FighterUnit)->String:
	var damage:String = Meta.get_unit_damage_string(unit);
	var stun_duration_str:String = Meta.get_technique_scaled_string(unit, "stun_duration")
	
	var string:String = "Punches forward, dealing " + damage + \
	" damage and to enemies in a small area and stunning them for "\
	 + stun_duration_str + " seconds.";
	return string;

const tags = [
	"brawler",
	"bodybuilder"
]

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;

const skill_range = 100;
const skill_cooldown = 5;

const stun_duration = 2;
