extends FighterBase


const skill_effects = ["self_buff"];
const skill_visuals = ["grow"]

const skill_use_sfx = ["defense_up"]
const skill_hit_sfx = []

const sample_offset = Vector2(35, -26)

const target_type = "nearest_enemy"

const skill_name = "Buckle up"
const description = "[color=blue]Doesn't deal damage.[/color] Shields self, becoming progressively more resistant."
const long_description = "Can be extremely difficult to take down."

func full_skill_description(unit:FighterUnit)->String:
	var technique_str:String = Meta.get_technique_scaled_string(unit);
	var base_value_str:String = Meta.get_color_tag("defense")+ str(stat_buff_values.defense) + "[/color]"
	var final_value_str:String = Meta.get_color_tag("defense")+ str(stat_buff_values.defense * unit.stats.technique) + "[/color]";
	
	var string:String = "[color=blue]Doesn't deal damage.[/color] Shields himself, gaining " + base_value_str + " * " + technique_str\
	 + " (" + final_value_str +") defense until the end of battle.";
	return string

const tags = [
	"juggernaut",
	"mechanic",
	"bodybuilder"
]

const hitbox_radius = 35;
const hitbox_height = 80;
const hitbox_offset = Vector2(-5, 0);

const hit_scan_radius = 100;

const skill_range = MELEE_RANGE;
const skill_cooldown = 3;

const buff_type = "stat";

const stats_to_buff = ["defense"]
const stat_buff_values = {
	"defense":5
}
