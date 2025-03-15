extends FighterBase


const skill_effects = ["aoe_damage", "aoe_stun"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const tags = [
	"juggernaut",
	"disruptor",
	"bodybuilder"
]

const skill_name = "Throw More Hands"
const description = "Damages and stuns enemies in a large area."
const long_description = "Very resistant and disruptive."


func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Meta.get_unit_damage_string(unit);
	var stun_duration_str:String = Meta.get_technique_scaled_string(unit, "stun_duration");
	
	var string:String = "Slams the ground with both arms, dealing " + damage_str +\
	" damage to enemies in a large area and stunning them for " + stun_duration_str + " seconds."
	return string

const stun_duration = 4;

const hitbox_radius = 35;
const hitbox_height = 80;
const hitbox_offset = Vector2(0, 5);

const hit_scan_radius = 200;
const skill_range = MELEE_RANGE;



const skill_cooldown = 5;
