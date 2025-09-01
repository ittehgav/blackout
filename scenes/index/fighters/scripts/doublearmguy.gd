extends FighterBase


const sample_offset = Vector2(15, -37)

const skill_name = "Throw Both Hands"
const description = "Damages and stuns enemies in a large area."
const flavor = "Every day is arm day."


func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	var stun_duration_str:String = Index.get_technique_scaled_string(unit, "stun", "status_duration");
	
	var string:String = "Slams the ground with both arms, dealing " + damage_str +\
	" to enemies in a large area and stunning them for " + stun_duration_str + " seconds."
	return string

const skill_range = MELEE_RANGE;
const skill_cooldown = 6;



const status_duration = .5;

func skill()->void:
	Combat.set_windup_angle(fighter);
	Combat.set_aoe_aim(fighter);
	
	animation_player.play("double_arm/skill");
	animation_player.queue("fighter_base/idle")

func skill_impact()->void:
	if fighter.dead:
		return;
	
	Combat.aoe_damage(fighter);
	Combat.aoe_stun(fighter);
	skill_finished.emit();
