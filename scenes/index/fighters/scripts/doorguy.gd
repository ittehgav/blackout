extends FighterBase

@export var self_buff:Status;

const skill_name = "Challenge"
@onready var description:String = Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color] Steals defense from nearby enemies."
const flavor = "The doors bend and break often enough without him hitting anyone with them."



func full_skill_description(unit:FighterUnit)->String:
	## text says reduced so number needs to be positive
	var reduction_str:String = Index.get_technique_scaled_string(unit, "stat_change", '', -status.value)
	var defense_gain_str:String = Index.get_technique_scaled_string(unit, "stat_change", '', -status.value/2)
	
	var string:String = Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color]\nChallenges nearby enemies, reducing their "+Index.stat_colored_name("defense").to_lower()+" by "\
	+ reduction_str + " and gaining " + Index.get_color_tag("defense") + defense_gain_str + " defense.";
	return string


const skill_range = MELEE_RANGE;
const skill_cooldown = 5;

const buff_type = "stat";

const stats_to_buff = ["defense"]


func skill()->void:
	animation_player.play("doorguy/skill");
	animation_player.queue("fighter_base/idle")

func skill_effect()->void:
	Combat.aoe_status(fighter);
	var buff_count:int = len(fighter.hit_targets);
	self_buff.apply_on_target(fighter, (self_buff.value/2) * buff_count)
		
