extends FighterBase

const no_damage = true;


const sample_offset = Vector2(15, -26)
const target_type = "nearest_enemy"

const skill_name = "Challenge"
@onready var description:String = Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color] Taunts nearby enemies and shields self, becoming progressively more resistant."
const flavor = "The doors bend and break often enough without him hitting anyone with them."



func full_skill_description(unit:FighterUnit)->String:
	var technique_str:String = Index.get_technique_scaled_string(unit, "stat_buff", "", stat_buff_values["defense"]);
	var base_value_str:String = Index.get_color_tag("defense")+ str(stat_buff_values.defense) + "[/color]"
	var final_value_str:String = Index.get_color_tag("defense")+ str(stat_buff_values.defense * unit.stats.technique) + "[/color]";
	
	var string:String = Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color] Shields himself, gaining " + final_value_str + " (" + base_value_str + " * " + technique_str\
	 + ") "+Index.stat_colored_name("defense") + " until the end of battle.";
	return string

const hitbox_radius = 35;
const hitbox_height = 80;
const hitbox_offset = Vector2(-5, 0);

const skill_range = MELEE_RANGE;
const skill_cooldown = 5;

const buff_type = "stat";

const stats_to_buff = ["defense"]
const stat_buff_values = {
	"defense":5
}

func skill()->void:
	animation_player.play("doorguy/skill");
	animation_player.queue("fighter_base/idle")

func skill_impact()->void:
	Combat.self_stat_buff(fighter);
	Combat.aoe_taunt(fighter)
