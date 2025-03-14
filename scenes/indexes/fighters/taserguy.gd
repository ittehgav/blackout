extends FighterBase


const skill_effects = ["stun", "direct_damage"];
const skill_visuals = ["recoil"]

const target_type = "nearest_enemy"

const tags = [
	"disruptor",
	"scientist"
]

const skill_name = "Taser Shot"
const description = "Deals light damage and stuns target."
const long_description = "Utility unit.\nCan be upgraded to heal allies or for heavy AOE damage."

func full_skill_description(unit:FighterUnit)->String:
	var damage_str = Meta.get_unit_damage_string(unit);
	var stun_duration = Meta.get_technique_scaled_string(unit, "stun_duration");
	
	var str:String = "Deals " + damage_str + " damage to a target and stuns them for "\
	 + stun_duration + " seconds.";
	return str


const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = 300;
const skill_cooldown = 1;

const stun_duration = .75
