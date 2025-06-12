extends FighterBase


const skill_visuals = ["lunge_forward", "hook"]
const projection_vfx = ["aoe_circle"];
## not stunning??
const skill_use_sfx = ["swing"]
const skill_hit_sfx = ["slam"]



const sample_offset = Vector2(23, -37)
const target_type = "nearest_enemy"

const skill_name = "Throw Both Hands"
const description = "Damages and stuns enemies in a large area."
const flavor = "Every day is arm day."

const tags = [
	"juggernaut",
	"disruptor",
	"bodybuilder"
]

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	var stun_duration_str:String = Index.get_technique_scaled_string(unit, "status_duration");
	
	var string:String = "Slams the ground with both arms, dealing " + damage_str +\
	" to enemies in a large area and stunning them for " + stun_duration_str + " seconds."
	return string

const hitbox_radius = 35;
const hitbox_height = 80;
const hitbox_offset = Vector2(0, 5);

const skill_range = MELEE_RANGE;
const skill_cooldown = 8;
const hit_scan_radius = 200;


const status_duration = .25;

func skill()->void:
	Combat.aoe_damage(fighter);
	Combat.aoe_stun(fighter);
