extends FighterBase

const skill_name = "Shockwave"
const description = "Knocks back and stuns enemies."
const flavor = "He's not entierly sure how it works either."


const skill_range = MID_RANGE;
const skill_cooldown = 6;



const knock_back_distance = 400;

const status_duration = 2.0;



func full_skill_description(unit:FighterUnit)->String:
	var stun_duration_string:String = Index.get_technique_scaled_string(unit, "stun", "", status.duration);

	var string:String = Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color]\nKnocks back an enemy target and"+Index.get_color_tag("stun")+" stuns[/color] them and any enemies they collide with for "\
	+ stun_duration_string + " seconds.";
	return string;


func skill()->void:
	Combat.set_aoe_aim(fighter);
	animation_player.play("gravity/skill")
	animation_player.queue("fighter_base/idle");

func skill_effect()->void:
	Combat.knock_back_target(fighter)
	Combat.aoe_status(fighter)
	if fighter.target_unit not in fighter.hit_targets:
		## they may walk out of the AOE during the windup but they still need to be stunned
		## and without this filter sometimes they'd get 2 identical stun timrs
		status.apply_on_target(fighter.target_unit)
	

func update_hit_scan()->void:
	if fighter.target_unit:
		hit_scan.get_node("shape").shape.size.y = fighter.target_unit.get_node("hitbox").shape.height
	
