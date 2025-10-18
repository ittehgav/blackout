extends FighterBase


const skill_name = "Challenge"
@onready var description:String = Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color] Steals defense from nearby enemies."
const flavor = "The doors bend and break often enough without him hitting anyone with them."



func full_skill_description(unit:FighterUnit)->String:
	## TODO make this a shield instead?
	## that scales with the amount of targets taunted?
	var reduction_str:String = Index.get_technique_scaled_string(unit, "stat_debuff", '', defense_steal)
	var defense_gain_str:String = Index.get_technique_scaled_string(unit, "stat_debuff", '', defense_steal/2)
	
	var string:String = Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color]\nChallenges nearby enemies, reducing their "+Index.stat_colored_name("defense").to_lower()+" by "\
	+ reduction_str + " and gaining " + Index.get_color_tag("defense") + defense_gain_str + " defense.";
	return string


const skill_range = MELEE_RANGE;
const skill_cooldown = 5;

const buff_type = "stat";

const stats_to_buff = ["defense"]

const defense_steal:= 5

func skill()->void:
	animation_player.play("doorguy/skill");
	animation_player.queue("fighter_base/idle")

func skill_effect()->void:
	Combat.aoe_stat_debuff(fighter, hit_scan, "defense", defense_steal)
	var buff_count:int = len(fighter.hit_targets);
	Combat.self_stat_buff(fighter, "defense", (defense_steal/2)*buff_count);
	
