extends FighterBase

const skill_name =  "Wrecking Punch"
const description = "Launches quick, powerful punches that reduce the defense of the target."
const flavor = "He still uses the robotic arm to lift weights and it's been so long it's weird to tell him."



func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	var def_reduction_str:String = Index.get_technique_scaled_string(unit,"stat_change", "", -status.value);

	var string:String = "Deals "+damage_str + " to the nearest enemy and reduces their "+Index.stat_colored_name("defense")+\
	" by "+  def_reduction_str + " for the rest of the battle.";
	return string;



const skill_range = MELEE_RANGE;
const skill_cooldown = 3;
const debuff_type = "stat";


const defense_reduction = 5;
func skill()->void:
	Combat.set_windup_angle(fighter)
	animation_player.play("mech_arm/skill")
	animation_player.queue("fighter_base/idle")
	
func skill_effect()->void:
	Combat.deal_damage(fighter)
	status.apply_on_target();
	skill_finished.emit();
