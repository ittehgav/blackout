extends FighterBase


const skill_effects = ["direct_damage"];
const skill_visuals = ["lunge_forward", "recoil_target"]

const skill_use_sfx = ["swing"]
const skill_hit_sfx = ["metal"]

const sample_offset = Vector2(13, -26)

const target_type = "nearest_enemy"


const skill_name =  "Crowbar Swing"
const description = "Low resistance, high melee damage."

func damage_modifier(damage:float, unit:FighterUnit=null)->float:
	if not unit:
		if fighter.technique >= 2:
			return damage * fighter.technique/2;
		else:
			return damage
	else:
		if unit.stats.technique >= 2:
			return damage * unit.stats.technique/2;
		else:
			return damage

func full_skill_description(unit:FighterUnit)->String:
	var base_damage_str:String = Meta.get_color_tag("attack") +  str(unit.stats.attack) + "[/color]";

	var final_damage_color_hex:String = Meta.stat_colors.attack.blend(Meta.stat_colors.technique).to_html();
	var final_damage_str:String = Meta.get_unit_damage_string(unit);
	final_damage_str= "[color=" + final_damage_color_hex + "]" + final_damage_str + "[/color]"
	
	var technique_str:String = Meta.get_technique_scaled_string(unit, "", 0, .5);
	
	var string:String = "Deals (" + base_damage_str + " * " + technique_str + ") = ("+ final_damage_str + ") damage to the nearest enemy.";

	string += "\n\nCan be upgraded to deal heavy, long-range damage or to apply AOE crowd control.";
	return string;


const tags = [
	"hunter",
	"scientist"
]



const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = MELEE_RANGE;

const debuff_type = "stat";
const skill_cooldown = 2;

const stats_to_debuff = ["defense"];
const stat_debuff_values = {
	"defense":5
}
