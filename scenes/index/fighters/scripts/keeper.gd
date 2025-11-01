extends FighterBase;

const sample_offsec = Vector2(11, -26);


const skill_name = "Swarm";
const description = "Flings a clould of insects at enemies, dealing damage and dereasing their agility.";

const flavor = "He can't fall asleep without feeling the stings.";

const skill_cooldown = 3;
const skill_range = MID_RANGE


func damage_modifier(damage:float, unit:FighterUnit = null)->float:
	if not unit:
		return Scaling.technique_scaled_value(damage/5, fighter.technique, "damage")
	else:
		return Scaling.technique_scaled_value(damage/5, unit.stats.technique, "damage")


func full_skill_description(unit:FighterUnit)->String:
	var base_damage_str:String = Index.get_color_tag("damage") + str(unit.stats.attack/5) + "[/color]";


	var final_damage_color_hex:String = Index.stat_colors.attack.blend(Index.stat_colors.technique).to_html();
	var final_damage_str:String = Index.get_unit_damage_string(unit);
	
	final_damage_str = "[color=" + final_damage_color_hex + "]" + final_damage_str + "[/color]"
	
	var technique_str:String = Index.get_color_tag("technique") + str(snapped(unit.stats.technique * Scaling.technique_mechanic_multipliers["damage"], .01)) + "[/color]"
	var final_string:String = "Flings a swarm that deals " + final_damage_str + " ("+base_damage_str+" + " + base_damage_str + " * " + technique_str + ") damage per second over 5 seconds.\nHitting the same target makes the bees sting faster.";
	return final_string;



@export var projectile:Projectile;
@export var bees:Sprite2D;


func skill()->void:
	Combat.set_windup_angle(fighter);
	animation_player.play("keeper/skill");
	animation_player.queue("fighter_base/idle")
	
func skill_effect()->void:
	Combat.shoot_projectile(projectile, fighter, bees_hit);


func bees_hit(target:ActiveFighter)->void:
	if not "swarm" in target.special_statuses:
		var new_bees:Sprite2D = bees.duplicate(DUPLICATE_SIGNALS + DUPLICATE_SCRIPTS);
		target.add_child(new_bees);
		new_bees.position = Vector2.ZERO
		new_bees.scale = Vector2(2, 2)
		new_bees.offset = Vector2(10, 0);
		
		var sting_timer:Timer = new_bees.get_node("sting")
		sting_timer.start();
		sting_timer.timeout.connect(bees_sting.bind(target))
		
		new_bees.get_node("shuffle").start();

		
		new_bees.frame_coords.y = 4;
		var new_status:Status = status.apply_on_target(target);
		new_status.associated_node = new_bees;
	
	else:
		var current_status:Status = target.special_statuses["swarm"];
		var current_bees:Sprite2D = current_status.associated_node;
		
		var sting_timer:Timer = current_bees.get_node("sting")
		sting_timer.wait_time -= sting_timer.wait_time/10;
		
		var shuffle_timer:Timer = current_bees.get_node("shuffle");
		shuffle_timer.wait_time -= shuffle_timer.wait_time/10;
		
		if current_bees.frame_coords.y < 4:
			current_bees.frame_coords.y += 1;
			
		var tween:Tween = create_tween();
		const interval = .2
		tween.tween_property(current_bees, "scale", Vector2(4, 4), interval);
		tween.tween_property(current_bees, "scale", Vector2(2, 2), interval)


func bees_sting(target:ActiveFighter)->void:
	print("stin? ", target.name)
	Combat.deal_damage(fighter, target, damage_modifier)
	
