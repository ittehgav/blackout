extends FighterBase


const sample_offset = Vector2(1, -26)
const target_type = "nearest_enemy"

const skill_name = "Shockwave"
const description = "Knocks back and stuns enemies."
const flavor = "He's not entierly sure how it works either."


const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = 300;
const skill_cooldown = 6;



const knock_back_distance = 400;

const status_duration = 1.0;



func full_skill_description(unit:FighterUnit)->String:
	var stun_duration_string:String = Index.get_technique_scaled_string(unit, "stun", "status_duration");
	var string:String = Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color] Knocks back an enemy target and"+Index.get_color_tag("stun")+" stuns[/color] them and any enemies they collide with for "\
	+ stun_duration_string + " seconds.";
	return string;




func skill()->void:
	if fighter.dead:
		return;
	Combat.set_aoe_aim(fighter);
	animation_player.play("gravity/skill")
	animation_player.queue("fighter_base/idle");

func skill_impact()->void:
	Combat.knock_back_target(fighter)
	Combat.aoe_stun(fighter)
	Combat.stun_target(fighter);

func update_hit_scan()->void:
	if fighter.target_unit:
		hit_scan.get_node("shape").shape.size.y = fighter.target_unit.get_node("hitbox").shape.height
	
