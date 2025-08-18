extends FighterBase


const sample_offset = Vector2(10, -16)

const target_type = "nearest_enemy"

const skill_name = "Rusty Pipe"
const description = "Moderate resistance and damage, attacks reduce enemies' damage."
const flavor = "Would be a lot less effective if he had better personal hygiene."


const attack_reduction = 10;

const hitbox_radius = 40;
const hitbox_height = 100;
const hitbox_offset = Vector2(0, -5)

const skill_range = MELEE_RANGE;
const skill_cooldown = 4;
const hit_scan_radius = 100;


const evolutions = {
	"Wheel Guy":{
		"fuel":50,
		"scrap":50
	},
	"Door Guy":{
		"juice":50,
		"scrap":50
	}
}

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	var atk_reduction_str:String =  Index.get_technique_scaled_string(unit, "stat_debuff", "", attack_reduction);
	
	var string:String = "Deals " + damage_str + " to enemies in an area and reduces their "+Index.stat_colored_name("attack") + \
	" by " + atk_reduction_str + "% for the rest of the battle.";
	string += "\n\nCan be [u]upgraded[/u] to become extremely resistant or to deal strong AOE damage."
	return string;


func skill()->void:
	Combat.set_windup_angle(fighter);
	animation_player.play("tailpipe/skill");
	animation_player.queue("fighter_base/idle");

func skill_impact()->void:
	if fighter.dead:
		return;
	Combat.deal_damage(fighter);
	Combat.apply_stat_change(fighter, fighter.target_unit, -attack_reduction, "attack")
	skill_finished.emit();
