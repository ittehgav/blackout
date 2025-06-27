extends FighterBase


const skill_visuals = ["lunge_forward", "shrink_target", "hook"]
const projection_vfx = ["aoe_circle"];

const skill_use_sfx = ["swing"]
const skill_hit_sfx = ["metal"]

const skill_windup = true;

const sample_offset = Vector2(15, -26)

const target_type = "nearest_enemy"

const skill_name =  "Wrecking Punch"
const description = "Throws a powerful punch that reduces the defense of the target."
const flavor = "He still uses the robotic arm to lift weights and it's been so long it's weird to tell him he doesn't need to now."

const tags = [
	"juggernaut",
	"cyborg",
	"brawler"
]

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	var def_reduction_str:String = Index.get_technique_scaled_string(unit,"stat_debuff", "", stat_debuff_values.defense);

	var string:String = "Deals "+damage_str + " to enemies in an area and reduces their "+Index.stat_colored_name("defense")+\
	" by "+  def_reduction_str + " for the rest of the battle.";
	return string;

const hitbox_radius = 35;
const hitbox_height = 100;
const hitbox_offset = Vector2.ZERO;

const skill_range = MELEE_RANGE;
const hit_scan_radius = 100;
const skill_cooldown = 3;

const debuff_type = "stat";

const stats_to_debuff = ["defense"];
const stat_debuff_values = {
	"defense":5
}

func skill()->void:
	Combat.aoe_damage(fighter);
	Combat.aoe_stat_debuff(fighter);
	
