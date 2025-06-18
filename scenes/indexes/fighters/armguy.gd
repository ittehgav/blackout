extends FighterBase

const skill_visuals = ["lunge_forward", "hook"]
const projection_vfx = ["aoe_circle"]

const skill_use_sfx = ["swing"]
const skill_hit_sfx = ["slam"]


## offset to be used on sprite samples
const sample_offset = Vector2(19, -42);

const target_type = "nearest_enemy"

const skill_name = "Throw Hands"
const description = "Slow and tough, damages and stuns enemies in an area."
const flavor = "He's heard that joke you're thinking of a thousand times."

const tags = [
	"brawler",
	"bodybuilder"
]

func full_skill_description(unit:FighterUnit)->String:
	var damage:String = Index.get_unit_damage_string(unit);
	var stun_duration_str:String = Index.get_technique_scaled_string(unit, "stun", "status_duration")
	
	var string:String = "Punches forward, dealing " + damage + \
	" to enemies in a small area and "+Index.get_color_tag("stun") + "stunning[/color] them for "\
	 + stun_duration_str + " seconds.";

	string += "\n\nCan be [u]upgraded[/u] to deal much more damage or to apply crowd control over a large area."
	return string;


const hitbox_radius = 30;
const hitbox_height = 80;
const hitbox_offset = Vector2(0, 10)


const skill_range = MELEE_RANGE;
const skill_cooldown = 8;
const hit_scan_radius = 100;

const status_duration = .125;


const evolutions = {
	"double_arm_guy":{
		"food":50,
		"juice":50
	},
	"mech_arm_guy":{
		"scrap":50,
		"chips":20
	}
}

func skill()->void:
	Combat.aoe_damage(fighter);
	Combat.aoe_stun(fighter);
